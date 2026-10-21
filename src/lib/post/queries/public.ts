import { PostModelFromApi } from '@/models/post/post-model';
import { apiRequest } from '@/utils/api-request';
import { cache } from 'react';

export const findAllPublicPostsFromApiCached = cache(async () => {
  const postsResponse = await apiRequest<PostModelFromApi[]>(`/post`, {
    next: {
      tags: ['posts'],
      revalidate: 86400,
    },
  });

  return postsResponse;
});

export const findPublicPostBySlugFromApiCached = cache(async (slug: string) => {
  const postsResponse = await apiRequest<PostModelFromApi>(`/post/${slug}`, {
    next: {
      tags: [`post-${slug}`],
      revalidate: 86400,
    },
  });

  return postsResponse;
});
