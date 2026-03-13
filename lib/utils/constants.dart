const String kWordpressUrl = 'https://summitoacps.com';

// ===============================
// WORDPRESS CORE
// ===============================

const String kApiPosts = '$kWordpressUrl/wp-json/wp/v2/posts?_embed';

const String kApiAboutPage =
    '$kWordpressUrl/wp-json/wp/v2/pages?slug=apropos&_embed';

const String kApiMedia = '$kWordpressUrl/wp-json/wp/v2/media';

const String kAppApiMediaUrl = '$kWordpressUrl/wp-json/eventin-api/v1/media';

// ===============================
// CUSTOM EVENTIN API (RECOMMANDÉ)
// ===============================

const String kApiEvents = '$kWordpressUrl/wp-json/eventin-api/v1/events';

String kApiEventDetail(int id) =>
    '$kWordpressUrl/wp-json/eventin-api/v1/events/$id';

const String kApiSpeakers = '$kWordpressUrl/wp-json/eventin-api/v1/speakers';

String kApiSpeakerDetail(int id) =>
    '$kWordpressUrl/wp-json/eventin-api/v1/speakers/$id';

const String kCustomApiBase = '$kWordpressUrl/wp-json/eventin-api/v1';

// Events
const String kCustomApiEventsUrl = '$kCustomApiBase/events';
String customEventDetailUrl(int id) => '$kCustomApiBase/events/$id';

// Program
const String kCustomApiProgramUrl = '$kCustomApiBase/program';

// Speakers
const String kCustomApiSpeakersUrl = '$kCustomApiBase/speakers';
String customSpeakerDetailUrl(int id) => '$kCustomApiBase/speakers/$id';

// ===============================
// WEGLOT API
// ===============================
const String kWeglotApiKey =
    'wg_571d4ee7d51660a4f49aa8d7a974048c0'; // REMPLACEZ PAR VOTRE CLÉ API
const String kWeglotApiUrl = 'https://api.weglot.com/translate';

// ===============================
// SMUGMUG API
// ===============================
const String kSmugmugApiKey =
    'HVLPd37MQd7nmpFzjh5Tq7pXgqx3Tt7h'; // REMPLACEZ PAR VOTRE CLÉ API
const String kSmugmugApiSecret =
    'pb8Qtj2hZHHJzL2Mgn6jQgmqz6cP5wdJH58tG4dSQS8t3RFnwk85RnvHHDtPF3rv'; // REMPLACEZ PAR VOTRE SECRET API
const String kSmugmugApiUrl = 'https://api.smugmug.com/api/v2';
const String kSmugmugUser =
    'oacps-pictures'; // Utilisateur identifié via le lien fourni

// ===============================
// RESEND API
// ===============================
const String kResendApiKey =
    're_6Gqx5kKR_8TKB9d2GcsYGWqrEp3WLAt29'; // REMPLACEZ PAR VOTRE CLÉ API RESEND
const String kResendApiUrl = 'https://api.resend.com/emails';
const String kAdminEmail =
    'dieudonnegwet86@gmail.com'; // Email de l'admin qui reçoit les notifs
