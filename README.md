# Flutter High Performance Feed

## Architecture

State management is implemented using Riverpod.

## Features

- Infinite scrolling
- Pagination (10 items)
- Pull to refresh
- Hero animations
- Detail screen
- Optimistic likes
- Offline revert
- CachedNetworkImage
- RepaintBoundary
- Supabase backend integration

## Performance

- RepaintBoundary used for feed cards
- memCacheWidth used for image memory optimization
- CachedNetworkImage used for caching
- Pagination prevents loading all posts at once

## Backend

- Supabase Database
- Supabase Storage
- Supabase RPC toggle_like