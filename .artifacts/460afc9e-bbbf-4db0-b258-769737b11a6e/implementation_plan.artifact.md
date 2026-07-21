# Implementation Plan - Fix Logout Stuck Issue

The user reported being stuck on the same page when attempting to log out. Investigation revealed that the logout logic in `AgentProfileController` attempts to navigate to `Routes.USER_TYPE` for the `cbe` client, but this route is not registered in `AppPages`. Additionally, logout logic across different views is inconsistent and sometimes uses incorrect navigation methods (like `Get.toNamed` instead of `Get.offAllNamed`).

## Proposed Changes

### [AppPages](file:///C:/Users/vishu/Documents/GitHub/AavinFleetApp/lib/app/routes/app_pages.dart)
- Register the `USER_TYPE` route in the `routes` list so that navigation to `/user-type` works correctly.

### [AgentProfileController](file:///C:/Users/vishu/Documents/GitHub/AavinFleetApp/lib/app/modules/agent/profile/views/agent_profile_view.dart)
- Refactor `showLogoutDialog` to use `SessionManager.clearSession()` for consistency.
- Ensure `Get.offAllNamed` is used for both branches of the logout navigation to completely clear the stack.
- Remove redundant `Get.deleteAll()` or ensure it doesn't interfere with the navigation.

### [AgentDrawer](file:///C:/Users/vishu/Documents/GitHub/AavinFleetApp/lib/app/modules/agent/drawer/views/agent_drawer_view.dart)
- Refactor `_showLogoutDialog` to use `SessionManager.clearSession()`.
- Use the same consistent navigation logic as `AgentProfileController`.

### [ProfileView](file:///C:/Users/vishu/Documents/GitHub/AavinFleetApp/lib/app/modules/agent/profile/views/profile_view.dart)
- Fix `_showLogoutDialog` to use `Get.offAllNamed` instead of `Get.toNamed`.
- Use `SessionManager.clearSession()` to clear data.

## Verification Plan

### Manual Verification
1.  Open the app and log in as a Fleet User.
2.  Open the drawer and tap "Log Out". Confirm the dialog.
3.  Verify that the app redirects to the Login screen (or User Type screen if applicable for `cbe`) and clears the navigation stack.
4.  Navigate to the Profile screen and tap the logout action. Confirm the dialog.
5.  Verify that the app redirects correctly and the session is cleared.
6.  Test with the `cbe` client configuration specifically to ensure the `USER_TYPE` redirection works (if that's the intended behavior).
