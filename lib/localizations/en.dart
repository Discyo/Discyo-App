/*
 * Copyright (C) 2023  Petr Buchal, Vladimír Jeřábek, Martin Ivančo
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

import 'package:flutter/material.dart';
import 'package:discyo/localizations/localization.dart';

class DiscyoLocalizationEn extends DiscyoLocalization {
  static Map<String, String> _errors = {
    "albums_unsupported": "Sorry, albums are not yet supported.",
    "books_unsupported": "Sorry, books are not yet supported.",
    "cant_update_profile": "Sorry, we were unable to update your profile. "
        "Please try again later.",
    "code_incorrect": "Incorrect reset code. Please try again.",
    "unexpected": "Something went wrong. Please try again later.",
    "email_in_use": "This email is already registered",
    "empty_code": "Please enter the code you received",
    "empty_dropdown": "Please choose",
    "empty_email": "Please enter your email",
    "empty_field": "Please enter your",
    "empty_password": "Please enter your password",
    "empty_username": "Please enter your username",
    "empty_username_or_email": "Please enter your username or email",
    "games_unsupported": "Sorry, games are not yet supported.",
    "friends_unsupported": "Sorry, friends are not yet supported.",
    "invalid_email": "Email is invalid",
    "invalid_password": "Password must be at least 6 characters long",
    "invalid_username_characters":
        "Username may only contain alphanumerical characters or hyphen or underscore",
    "invalid_username_length": "Username must contain 3-32 characters",
    "login_incorrect": "Username or password is incorrect!",
    "no_internet": "No internet connection.\n"
        "Connect to the internet and try again.",
    "not_in_db": "This is not yet in our database, sorry about that!",
    "password_mismatch": "Passwords don't match.",
    "password_incorrect": "Incorrect password",
    "podcasts_unsupported": "Sorry, podcasts are not yet supported.",
    "server_down": "Darn, something went wrong on our side.",
    "shows_unsupported": "Sorry, shows are not yet supported.",
    "username_in_use": "This username is already in use",
  };

  static Map<String, String> _labels = {
    "cancel": "CANCEL",
    "cast": "Cast",
    "change_confidential": "Change username or password",
    "change_my_mind": "Change My Mind",
    "change_password": "Change password",
    "change_profile_picture": "Change profile picture",
    "choose": "Choose",
    "code": "Reset code",
    "community_discord": "Community Discord server",
    "confirm_delete_account_description":
        "This action can not be undone. Type \"Delete\" and press OK to proceed.",
    "confirm_delete_account_string": "Delete",
    "confirm_delete_account_title":
        "Are you sure you want to delete your account?",
    "confirmation_resent_description":
        "Please check your inbox and confirm your registration. You'll then be able to log in.",
    "confirmation_resent_title": "Confirmation email resent.",
    "country": "country",
    "crew": "Crew",
    "created_by": "Created by",
    "current_password": "Current password",
    "delete_account": "Delete account",
    "developed_by": "Developed by",
    "diary": "Diary",
    "director": "Director",
    "directed_by": "Directed by",
    "discover": "Discover",
    "discover_later": "Discover Later",
    "do_init": "Get to know me",
    "edit_profile": "Edit profile",
    "edit_account": "Edit account",
    "email": "Email",
    "email_not_confirmed":
        "Your account has not yet been confirmed. Please check your inbox and confirm your registration. You'll then be able to log in.",
    "executive_producer": "Executive Producer",
    "fans_also_like": "Fans also like",
    "favorites_title": "Favorites",
    "favorites_description":
        "Choose a few films or shows you like so that we can get to know your taste.",
    "feedback_placeholder": "Write feedback",
    "feedback_title": "How do you like the recommendations so far?",
    "feedback_toast": "How do you like the recommendations so far? "
        "Let us know so we can improve!",
    "forgot_password": "Forgot password",
    "friends": "Friends",
    "info_credit": "Information provided by ",
    "language": "language",
    "loading": "Loading...",
    "log_movie_toast": "Did you see a movie recently? "
        "Make sure to find and rate it on the Search tab!",
    "log_out": "Log out",
    "logging_in": "Logging in...",
    "login": "Log in",
    "login_apple": "Log in with Apple",
    "login_email": "Or log in with email",
    "login_google": "Log in with Google",
    "missing_info_title": "Please fill missing info abou you",
    "name": "Name",
    "needs_init":
        "Before we can recommend something,\nwe need to get to know you a bit.",
    "new_password": "New password",
    "new_password_again": "Repeat new password",
    "not_enough_ratings": "Not enough ratings",
    "ok": "OK",
    "onboarding_finish": "That's it!\nLet's get started!",
    "onboarding_gestures": "Let's try out the gestures",
    "onboarding_rate": "Press the star button to rate.",
    "onboarding_ratings": "(Ratings from tutorial are not saved)",
    "onboarding_rewind": "Press the rewind button to go back.",
    "onboarding_selectors":
        "Use the selectors at the top\nto choose medium. Try it out!",
    "onboarding_swipe_left": "Swipe left to dismiss.",
    "onboarding_swipe_right": "Swipe right to save.",
    "onboarding_welcome": "Welcome to Discyo",
    "password": "Password",
    "password_changed": "Password changed successfully!",
    "platforms": "Filter streaming services",
    "platforms_title": "Streaming services",
    "platforms_description":
        "Would you like to filter recommendations to those available on certain streaming services only? Choose them below or leave it empty to get all recommendations. You can change filtered streaming services anytime in account settings.",
    "privacy_policy": "Privacy Policy",
    "rate": "RATE",
    "register": "Sign up",
    "register_acknowledge_1": "By signing up you are accepting our ",
    "register_acknowledge_2": "Terms & Conditions",
    "register_acknowledge_3": " and ",
    "register_acknowledge_4": "Privacy Policy",
    "register_acknowledge_5": ".",
    "register_apple": "Sign up with Apple",
    "register_email": "Sign up with email",
    "register_google": "Sign up with Google",
    "report_problem_placeholder": "Describe the problem",
    "report_problem_title": "Report problem",
    "resend_email": "Send email again",
    "resend_email_question": "Didn't get an email?",
    "successful_registration_title": "Successfully signed up!",
    "successful_registration_description":
        "Please check your inbox and confirm your registration. You'll then be able to log in.",
    "repeated": "Repeated",
    "reset_successful": "Password changed successfully. You can now log in.",
    "saving": "Saving...",
    "search": "Search",
    "search_bar": "What are you in the mood for?",
    "send": "SEND",
    "sending_init": "Getting to know you...",
    "show_more": "Show\nmore",
    "skip": "SKIP",
    "submit": "Submit",
    "terms_and_conditions": "Terms & Conditions",
    "thanks_for_feedback": "Thank you for your feedback!",
    "trailer": "Trailer",
    "unknown_creator": "Unknown Creator",
    "unknown_director": "Unknown Director",
    "username": "Username",
    "username_or_email": "Username or email",
    "video": "Video",
    "watch_on": "Watch on",
    "yourself": "Yourself",
  };

  static Map<String, RichText> _documents = {
    "privacy_policy": RichText(
      text: TextSpan(
        text: "TODO",
        style: const TextStyle(fontSize: 12),
      ),
    ),
    "terms_and_conditions": RichText(
      text: TextSpan(
        text: "TODO",
        style: const TextStyle(fontSize: 12),
      ),
    ),
  };

  Map<String, String> get errors => _errors;
  Map<String, String> get labels => _labels;
  Map<String, RichText> get documents => _documents;
}
