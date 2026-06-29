# Riffy — Domain Context

## Platform Decision

- **Framework**: Flutter
- **Targets**: Windows + Android
- **Rationale**: Single codebase, 90% native UX quality, 50% dev cost vs two native apps

## Architecture

- **Data API**: Hybrid — InnerTube (reverse-engineered, custom Dart client) for streaming, search, recommendations, lyrics; YouTube Data API v3 for metadata, upload management where applicable.

## State Management

- **Approach**: Riverpod

## Authentication

- **Primary**: OAuth 2.0 device flow
- **Fallback**: Cookie/SAPISID extraction for advanced users

## Audio Playback

- **Engine**: `just_audio`
- **Background playback**: `audio_service`
- **Stream format**: AAC/MP4 stream variants (native decode, no transcoding)

## Design

- **Design goal**: Take best design qualities from Spotify and Apple Music
- **Approach**: Blended — Spotify-style bottom nav + mini-player with Apple Music's library depth
- **UI framework**: Material Design 3 with heavy customization
- **Navigation tabs**: Home, Search, Library
- **Routing**: go_router
- **Theme**: Dynamic colors on Android (Material You), custom dark theme on Windows

## Storage

- **Library cache**: drift (SQLite)
- **Auth/settings**: Hive

## Lyrics

- **Approach**: Synced (karaoke-style), post-MVP

## Future Ideas (post-MVP)

- **Dynamic album-art theming**: App adapts its color palette to the dominant colors of the currently playing album art (or the album/song being browsed). Colors should be washed out for light mode, darkened for dark mode — preventing any single album from making the UI ugly or unreadable.
