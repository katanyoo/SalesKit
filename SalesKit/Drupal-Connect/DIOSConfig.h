//
// DIOSConfig.h
//
// ***** BEGIN LICENSE BLOCK *****
// Version: MPL 1.1/GPL 2.0
//
// The contents of this file are subject to the Mozilla Public License Version
// 1.1 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
// http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis,
// WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
// for the specific language governing rights and limitations under the
// License.
//
// The Original Code is Kyle Browning, released June 27, 2010.
//
// The Initial Developer of the Original Code is
// Kyle Browning
// Portions created by the Initial Developer are Copyright (C) 2010
// the Initial Developer. All Rights Reserved.
//
// Contributor(s):
//
// Alternatively, the contents of this file may be used under the terms of
// the GNU General Public License Version 2 or later (the "GPL"), in which
// case the provisions of the GPL are applicable instead of those above. If
// you wish to allow use of your version of this file only under the terms of
// the GPL and not to allow others to use your version of this file under the
// MPL, indicate your decision by deleting the provisions above and replacing
// them with the notice and other provisions required by the GPL. If you do
// not delete the provisions above, a recipient may use your version of this
// file under either the MPL or the GPL.
//
// ***** END LICENSE BLOCK *****

//#define STAGE
#define DEV


#ifdef STAGE

#define DRUPAL_API_KEY  @""
#define DRUPAL_SERVICES_URL  @"http://stage.example.com/services/plist"
#define DRUPAL_URL  @"http://stage.example.com"
#define DRUPAL_DOMAIN @"stage.example.com" 

#endif

#ifdef DEV

#define DRUPAL_API_KEY  @"4b2d7ef98d720386e0d2022842847404"
//#define DRUPAL_SERVICES_URL  @"http://dev.example.com/services/plist"
#define DRUPAL_SERVICES_URL  @"http://saleskit.myiphone.in.th/api"
#define DRUPAL_URL  @"http://saleskit.myiphone.in.th"
#define DRUPAL_DOMAIN @"saleskit.myiphone.in.th" 
#endif
//THis is the constant for none in Drupal7 http://api.drupal.org/api/constant/LANGUAGE_NONE/7
#define DRUPAL_LANGUAGE @"und"
