# Conduit

Elm implementation of the front-end of Conduit (a medium clone) according to its [specification](https://github.com/gothinkster/realworld)

> **warning** data is fetched from conduit server, infinite loadings or inappropriate content are not related to this codebase

**[Demo](https://elm-real-world.vercel.app/)**


## Pages and functionality:

### Home

Functionality:

- Pagination
- Like post
- Multiple tabs
  - Personal feed (if logged)
  - Global feed
  - Tag

![Home](screenshots/home.jpg)

### View Post

Functionality:

- Parsing markdown
- Favorite post
- Follow author
- Post comment
- Read comments
- Edit comment (if logged in)
- Delete post (if logged in)
- Edit post (if logged in)

![Article](screenshots/article-slug.jpg)
![Article](screenshots/article-slug-1.jpg)

### View Profile

Functionality:

- Follow profile
- Pagination
- Multiple tabs
  - profile posts
  - profile likes

![Profile](screenshots/profile.jpg)

### Create/Edit post

![Editor](screenshots/editor.jpg)

### Login/Register

![Login](screenshots/login.jpg)
![Register](screenshots/register.jpg)

### Settings

![Settings](screenshots/settings.jpg)
