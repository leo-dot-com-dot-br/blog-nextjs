# Blog Next.js

Full-stack blog with a public reading area and an admin panel. Built with Next.js (App Router, Server Actions) and backed by its own REST API written in NestJS.

> Backend repository: [api-nestjs-for-blog](https://github.com/leo-dot-com-dot-br/blog-nestjs-api)

## Features

- Home page with a featured post and the post list
- Post page by slug, with Markdown rendered safely
- Sign up and login against the API
- Admin panel to create, edit and delete posts, with a Markdown editor and cover image upload
- User management: update profile, change password, delete account
- Admin routes redirect to the login page when there is no session cookie

## Tech Stack

- Next.js 16 (App Router, Server Actions), React 19 with the React Compiler, TypeScript
- Tailwind CSS 4 with the Typography plugin
- Zod 4 for validation
- `@uiw/react-md-editor` for editing; `react-markdown`, `remark-gfm` and `rehype-sanitize` for rendering
- `sanitize-html`, `react-toastify`, `lucide-react`, `date-fns`

## Architecture

```text
Browser  ->  Next.js (App Router)  ->  NestJS API  ->  Database
             Server Components: reads
             Server Actions: writes and uploads
```

The Next.js app never talks to the database. Data, authentication and image uploads all go through the REST API, which lives in a separate repository. Uploaded images are served by the API: the upload endpoint returns a path, and the front end prepends `IMAGE_SERVER_URL` to build the final address.

## Technical Decisions

**Reads and writes are separated.** Read operations live in `src/lib/*/queries` and are called from Server Components. Write operations are Server Actions in `src/actions`, which validate input with Zod before calling the API.

**Caching with on-demand invalidation.** Public post queries are cached for up to 24 hours and tagged (`posts` and `post-<slug>`). The Server Actions that create, update or delete a post call `updateTag`, so changes show up immediately instead of waiting for the cache to expire. Admin queries use `no-store` because they return per-user data.

**Authorization lives in the API.** The NestJS API issues the JWT. Next.js stores it in an `httpOnly`, `secure`, `sameSite: strict` cookie, so it is not readable from browser JavaScript. The proxy and the admin layout only check that the cookie exists, to control navigation; every protected request is validated by the API's JWT guard.

**Sanitization on input and on render.** Post content is sanitized with `sanitize-html` in the Zod schema and again with `rehype-sanitize` when rendering Markdown (and in the editor preview).

## Project Structure

| Path | Purpose |
| --- | --- |
| `src/app` | Routes (public pages, `/admin`, `/login`, `/user/new`) |
| `src/actions` | Server Actions: login, posts, users, upload |
| `src/lib` | Zod schemas, session handling and data queries |
| `src/components` | UI components |
| `src/utils` | API request helpers and small utilities |
| `src/proxy.ts` | Redirects visitors without a session cookie away from `/admin` |

## Getting Started

### Prerequisites

- Node.js 20.9 or later
- The [API](https://github.com/leo-dot-com-dot-br/blog-nestjs-api) running locally (default: `http://localhost:3001`)

### Installation

```bash
git clone https://github.com/leo-dot-com-dot-br/blog-nextjs.git
cd blog-nextjs
npm install
cp .env.local-EXAMPLE .env.local
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

> The production build (`npm run build`) fetches posts from the API, so the API must be reachable while it runs.

### Environment variables

| Variable | Description |
| --- | --- |
| `API_URL` | Base URL of the NestJS API, without trailing slash |
| `IMAGE_SERVER_URL` | Base URL prepended to the image path returned by the upload endpoint |
| `NEXT_PUBLIC_IMAGE_UPLOAD_MAX_SIZE` | Maximum image size in bytes, checked in the browser (the API enforces its own limit) |
| `LOGIN_COOKIE_NAME` | Name of the session cookie |
| `LOGIN_EXPIRATION_SECONDS` | Cookie lifetime in seconds (the token's own expiry is set by the API) |
| `ALLOW_LOGIN` | Feature flag: `1` allows login, `0` disables it |

If you change the API host, also update `images.remotePatterns` in `next.config.ts`.

## Scripts

| Command | Description |
| --- | --- |
| `npm run dev` | Start the development server |
| `npm run build` | Create the production build |
| `npm start` | Run the production build |
| `npm run lint` | Run ESLint |

## Project History

The first version read posts directly from a local SQLite database through Drizzle ORM. The project was then migrated to a dedicated NestJS API and the old data layer was removed. The tag `pre-organization` marks the last commit that still contains it.
