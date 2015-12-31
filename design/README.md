# Design Notes

## Services
- Auth : Authorization/Authentication, social plugin integration
- Movie : Everything about movies, search movie by name(autocomplete), find/edit movie attributes, Add new movie, Delete movie
- User : Represent an authenticated user in system, User feed, User pins (if we think this could be like pinterest for videos). Also provision for Guest user support (non authenticated)
- Rating : (Depends on Movie, User). Save/Read/Update/Delete a movie rating for a given user. Users may associate keywords as part of comment/review.
- Prediction : the core alogrithmic service. enumerate the list of methods this could contain
- Session : Represents a collabedit like session in system.Create/edit/save/archive/participate/rename sessions.

## Primary Entities
- Movie
- User
- Rating
- Group
