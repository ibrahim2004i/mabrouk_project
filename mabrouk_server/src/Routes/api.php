<?php
// 🛤️ Central API Route Registry
// Defining routes for Auth, Customer, Provider, and Admin.

namespace App\Routes;
use App\Core\Router;

// AUTH ROUTES
Router::post('/auth/login', 'AuthController@login');
Router::post('/auth/register/customer', 'AuthController@registerCustomer');
Router::post('/auth/register/provider', 'AuthController@registerProvider');
Router::post('/auth/profile/update', 'AuthController@updateProfile', ['auth']);

// 🔔 NOTIFICATIONS
Router::get('/notifications', 'NotificationController@index', ['auth']);
Router::post('/notifications/read', 'NotificationController@markRead', ['auth']);

// COMMON SERVICES (PUBLIC BRAWSING)
Router::get('/services/{type}', 'ServiceController@index');
Router::get('/services/{type}/{id}', 'ServiceController@show');

// CUSTOMER BOOKING FLOW
Router::post('/bookings', 'BookingController@store', ['auth']);
Router::get('/bookings/my-bookings', 'BookingController@customerIndex', ['auth']);

// PROVIDER SERVICE MANAGEMENT
Router::get('/provider/my-services', 'ServiceController@providerIndex', ['auth', 'provider']);
Router::post('/services/{type}', 'ServiceController@store', ['auth', 'provider']);
Router::put('/services/{type}/{id}', 'ServiceController@update', ['auth', 'provider']);

// PROVIDER DASHBOARD & BOOKINGS
Router::get('/provider/stats', 'DashboardController@stats', ['auth', 'provider']);
Router::get('/provider/bookings', 'BookingController@providerIndex', ['auth', 'provider']);
Router::get('/provider/services/{type}/{id}/bookings', 'BookingController@serviceBookings', ['auth', 'provider']);
Router::post('/provider/bookings/update-status', 'BookingController@updateStatus', ['auth', 'provider']);
Router::post('/provider/bookings/reschedule', 'BookingController@reschedule', ['auth', 'provider']);

// ADMIN MODERATION & MANAGEMENT
Router::get('/admin/pending-services', 'AdminController@pendingServices', ['auth', 'admin']);
Router::post('/admin/approve-service', 'AdminController@approveService', ['auth', 'admin']);
Router::post('/admin/reject-service', 'AdminController@rejectService', ['auth', 'admin']);

Router::get('/admin/providers', 'AdminController@listProviders', ['auth', 'admin']);
Router::get('/admin/providers/pending', 'AdminController@listPendingProviders', ['auth', 'admin']);
Router::get('/admin/provider-services', 'AdminController@getProviderServices', ['auth', 'admin']);
Router::post('/admin/providers/delete', 'AdminController@deleteProvider', ['auth', 'admin']);
Router::post('/admin/providers/update-status', 'AdminController@updateProviderStatus', ['auth', 'admin']);

Router::get('/admin/complaints', 'AdminController@listComplaints', ['auth', 'admin']);
Router::post('/admin/complaints/resolve', 'AdminController@resolveComplaint', ['auth', 'admin']);

// ---------------------------------------------------------
// 📸 FILE UPLOAD
// ---------------------------------------------------------
Router::post('/upload/profile', 'UploadController@uploadProfileImage', ['auth']);
Router::post('/upload/service-media', 'UploadController@uploadServiceMedia', ['auth', 'provider']);
Router::delete('/upload/delete', 'UploadController@deleteImage', ['auth']);

// ⭐ REVIEWS & RATINGS
Router::post('/reviews', 'ReviewController@store', ['auth']);
Router::get('/services/{type}/{id}/reviews', 'ReviewController@index');
Router::delete('/reviews/{id}', 'ReviewController@destroy', ['auth']);

// COMPLAINTS (CUSTOMER)
Router::post('/complaints', 'ComplaintController@store', ['auth']);

// CITIES & CATEGORIES
Router::get('/cities', 'ReferenceController@cities');
Router::get('/categories', 'ReferenceController@categories');

// 💖 FAVORITES
Router::post('/favorites/toggle', 'FavoriteController@toggle', ['auth']);
Router::get('/favorites', 'FavoriteController@index', ['auth']);

