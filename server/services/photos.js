import { getAuthClient } from '../utils/google-auth.js';
import config from '../utils/config.js';
import cache from '../utils/cache.js';

const ITEMS_TTL = 30 * 60 * 1000; // 30 minutes (base URLs expire ~60min)
const PHOTOS_API = 'https://photoslibrary.googleapis.com/v1';

let mediaItems = [];
let currentIndex = 0;
let lastRotation = 0;

async function fetchMediaItems(auth) {
  const cached = cache.get('photos:items');
  if (cached) return cached;

  // Find the album
  const token = (await auth.getAccessToken()).token;
  const headers = { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' };

  const albumName = config.photos?.albumName || 'Favorites';

  let albums = [];
  let pageToken = '';
  do {
    const url = `${PHOTOS_API}/albums?pageSize=50${pageToken ? `&pageToken=${pageToken}` : ''}`;
    const res = await fetch(url, { headers });
    if (!res.ok) break;
    const data = await res.json();
    albums = albums.concat(data.albums || []);
    pageToken = data.nextPageToken || '';
  } while (pageToken);

  const album = albums.find(a => a.title === albumName);
  if (!album) {
    console.warn(`Photos: album "${albumName}" not found`);
    return [];
  }

  // Fetch media items from album
  let items = [];
  let nextPage = '';
  do {
    const res = await fetch(`${PHOTOS_API}/mediaItems:search`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        albumId: album.id,
        pageSize: 100,
        ...(nextPage && { pageToken: nextPage }),
      }),
    });
    if (!res.ok) break;
    const data = await res.json();
    items = items.concat(
      (data.mediaItems || [])
        .filter(i => i.mimeType?.startsWith('image/'))
        .map(i => ({ id: i.id, baseUrl: i.baseUrl, width: i.mediaMetadata?.width, height: i.mediaMetadata?.height }))
    );
    nextPage = data.nextPageToken || '';
  } while (nextPage);

  cache.set('photos:items', items, ITEMS_TTL);
  return items;
}

export async function getPhotos() {
  if (!config.photos?.albumName) return null;

  const auth = await getAuthClient();
  if (!auth) return null;

  try {
    mediaItems = await fetchMediaItems(auth);
  } catch (err) {
    console.error('Photos fetch error:', err.message);
  }

  if (mediaItems.length === 0) return null;

  // Rotate based on time
  const interval = (config.photos?.rotateIntervalSeconds || 45) * 1000;
  const now = Date.now();
  if (now - lastRotation >= interval) {
    currentIndex = (currentIndex + 1) % mediaItems.length;
    lastRotation = now;
  }

  const item = mediaItems[currentIndex];
  return {
    current: `${item.baseUrl}=w3840-h2160`,
    albumName: config.photos.albumName,
    totalPhotos: mediaItems.length,
    currentIndex,
  };
}
