<?php
/**
 * Plugin Name: Custom EventIn Api
 * Description: Custom REST API for Eventin mobile integration
 * Version: 1.4.0
 * Author: Dieudonne GWET BIKOUN
 */

if (!defined('ABSPATH')) exit;

class EventIn_Custom_Api {

    /**
     * Meta keys possibles reliant un schedule (etn-schedule) à un event (etn).
     * Eventin varie selon versions/config.
     */
    private array $schedule_event_meta_keys = [
        'etn_event_id',
        'event_id',
        '_event_id',
        'etn_parent_event',
        'etn_schedule_event_id',
        'schedule_event_id',
        'etn_event',
    ];

    /**
     * Meta keys possibles start/end time sur schedule.
     */
    private array $schedule_time_meta_keys = [
        'etn_schedule_start_time',
        'etn_start_time',
        'start_time',
        'etn_shedule_start_time', // typo Eventin connu
        'etn_schedule_time',
    ];

    private array $schedule_end_time_meta_keys = [
        'etn_schedule_end_time',
        'etn_end_time',
        'end_time',
        'etn_shedule_end_time', // typo Eventin connu
    ];

    /**
     * Meta keys possibles speakers côté Event.
     */
    private array $event_speaker_meta_keys = [
        'etn_speakers',
        'etn_event_speaker',
        'event_speakers',
        'speakers',
        '_speakers',
    ];

    public function __construct() {
        add_action('rest_api_init', [$this, 'register_routes']);
    }

    public function register_routes() {

        /**
         * EVENTS (list)
         * GET /wp-json/eventin-api/v1/events?page=1&per_page=20&order=ASC&with_schedule=0&with_speakers=0
         */
        register_rest_route('eventin-api/v1', '/events', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_events'],
            'permission_callback' => '__return_true',
            'args' => [
                'page' => ['default' => 1, 'sanitize_callback' => 'absint'],
                'per_page' => ['default' => 20, 'sanitize_callback' => 'absint'],
                'order' => [
                    'default' => 'ASC',
                    'sanitize_callback' => function ($v) {
                        $v = strtoupper((string)$v);
                        return in_array($v, ['ASC', 'DESC'], true) ? $v : 'ASC';
                    }
                ],
                'with_schedule' => ['default' => 0, 'sanitize_callback' => 'absint'],
                'with_speakers' => ['default' => 0, 'sanitize_callback' => 'absint'],
            ],
        ]);

        /**
         * EVENT DETAIL
         * GET /wp-json/eventin-api/v1/events/{id}
         */
        register_rest_route('eventin-api/v1', '/events/(?P<id>\d+)', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_event_detail'],
            'permission_callback' => '__return_true'
        ]);

        /**
         * PROGRAM (grouped by date) - pour écran Programme global
         * GET /wp-json/eventin-api/v1/program?order=ASC&per_page=100
         */
        register_rest_route('eventin-api/v1', '/program', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_program'],
            'permission_callback' => '__return_true',
            'args' => [
                'order' => [
                    'default' => 'ASC',
                    'sanitize_callback' => function ($v) {
                        $v = strtoupper((string)$v);
                        return in_array($v, ['ASC', 'DESC'], true) ? $v : 'ASC';
                    }
                ],
                'per_page' => ['default' => 100, 'sanitize_callback' => 'absint'],
            ],
        ]);

        /**
         * SPEAKERS (list)
         * GET /wp-json/eventin-api/v1/speakers?page=1&per_page=200
         */
        register_rest_route('eventin-api/v1', '/speakers', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_speakers'],
            'permission_callback' => '__return_true',
            'args' => [
                'page' => ['default' => 1, 'sanitize_callback' => 'absint'],
                'per_page' => ['default' => 200, 'sanitize_callback' => 'absint'],
            ],
        ]);

        /**
         * SPEAKER DETAIL
         * GET /wp-json/eventin-api/v1/speakers/{id}
         */
        register_rest_route('eventin-api/v1', '/speakers/(?P<id>\d+)', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_speaker_detail'],
            'permission_callback' => '__return_true',
        ]);

        /**
         * MEDIA DETAIL (stable thumbnail)
         * GET /wp-json/eventin-api/v1/media/{id}
         */
        register_rest_route('eventin-api/v1', '/media/(?P<id>\d+)', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_media_detail'],
            'permission_callback' => '__return_true',
        ]);

        /**
         * MEDIA LIST (stable thumbnail) + pagination
         * GET /wp-json/eventin-api/v1/media?page=1&per_page=20&order=DESC&type=all|image|video
         */
        register_rest_route('eventin-api/v1', '/media', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_media_list'],
            'permission_callback' => '__return_true',
            'args' => [
                'page' => ['default' => 1, 'sanitize_callback' => 'absint'],
                'per_page' => ['default' => 20, 'sanitize_callback' => 'absint'],
                'order' => [
                    'default' => 'DESC',
                    'sanitize_callback' => function ($v) {
                        $v = strtoupper((string)$v);
                        return in_array($v, ['ASC', 'DESC'], true) ? $v : 'DESC';
                    }
                ],
                'type' => [
                    'default' => 'all',
                    'sanitize_callback' => function ($v) {
                        $v = strtolower((string)$v);
                        return in_array($v, ['all', 'image', 'video'], true) ? $v : 'all';
                    }
                ],
            ],
        ]);

        /**
         * PAGE (mobile-friendly): by slug
         * GET /wp-json/eventin-api/v1/page?slug=apropos
         * Optional: mode=mobile|raw (default mobile)
         */
        register_rest_route('eventin-api/v1', '/page', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_page'],
            'permission_callback' => '__return_true',
            'args' => [
                'slug' => [
                    'required' => true,
                    'sanitize_callback' => 'sanitize_title',
                ],
                'mode' => [
                    'default' => 'mobile',
                    'sanitize_callback' => function ($v) {
                        $v = strtolower((string)$v);
                        return in_array($v, ['mobile', 'raw'], true) ? $v : 'mobile';
                    }
                ],
            ],
        ]);

        /**
         * Convenience route: About page (slug fixed)
         * GET /wp-json/eventin-api/v1/pages/about
         */
        register_rest_route('eventin-api/v1', '/pages/about', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'get_about_page'],
            'permission_callback' => '__return_true',
        ]);

        /**
         * DEBUG schedule meta (optionnel)
         * GET /wp-json/eventin-api/v1/debug/schedule-meta/{id}
         */
        register_rest_route('eventin-api/v1', '/debug/schedule-meta/(?P<id>\d+)', [
            'methods'  => WP_REST_Server::READABLE,
            'callback' => [$this, 'debug_schedule_meta'],
            'permission_callback' => '__return_true'
        ]);
    }

    /**
     * ==============================
     * EVENTS LIST
     * ==============================
     */
    public function get_events(WP_REST_Request $request) {

        $page = max(1, (int)$request->get_param('page'));
        $per_page = max(1, min(50, (int)$request->get_param('per_page')));
        $order = (string)$request->get_param('order');
        $with_schedule = ((int)$request->get_param('with_schedule')) === 1;
        $with_speakers = ((int)$request->get_param('with_speakers')) === 1;

        $q = new WP_Query([
            'post_type'      => 'etn',
            'posts_per_page' => $per_page,
            'paged'          => $page,
            'post_status'    => 'publish',
            'orderby'        => 'meta_value',
            'meta_key'       => 'etn_start_date',
            'order'          => $order,
        ]);

        $data = [];

        foreach ($q->posts as $event) {
            $event_id = (int)$event->ID;

            $loc = $this->normalize_location(get_post_meta($event_id, 'etn_event_location', true));

            $row = [
                'id'         => $event_id,
                'title'      => $event->post_title,
                'slug'       => $event->post_name,

                // ✅ Compat Event.dart (Event.fromCustomApiJson lit json['description'])
                'description'       => wp_kses_post(apply_filters('the_content', $event->post_content)),
                'description_plain' => wp_strip_all_tags($event->post_content),

                'start_date' => (string)get_post_meta($event_id, 'etn_start_date', true),
                'end_date'   => (string)get_post_meta($event_id, 'etn_end_date', true),
                'start_time' => (string)get_post_meta($event_id, 'etn_start_time', true),
                'end_time'   => (string)get_post_meta($event_id, 'etn_end_time', true),
                'timezone'   => (string)get_post_meta($event_id, 'event_timezone', true),

                // ✅ Location clean (string)
                'location'     => $loc['text'],

                // utile si tu veux debug côté Flutter
                'location_obj' => $loc['obj'],

                'price'      => (float)get_post_meta($event_id, '_price', true),
                'is_free'    => ((float)get_post_meta($event_id, '_price', true) <= 0),
                'banner'     => $this->get_event_banner_url($event_id),
            ];

            if ($with_schedule) {
                $row['schedule'] = $this->get_schedules_for_event($event_id);
            }

            if ($with_speakers) {
                $row['speakers'] = $this->get_speakers_for_event($event_id);
            }

            $data[] = $row;
        }

        return rest_ensure_response([
            'page'       => $page,
            'per_page'   => $per_page,
            'total'      => (int)$q->found_posts,
            'total_page' => (int)$q->max_num_pages,
            'data'       => $data,
        ]);
    }

    /**
     * ==============================
     * EVENT DETAIL
     * ==============================
     */
    public function get_event_detail(WP_REST_Request $request) {

        $id = (int)$request['id'];
        $event = get_post($id);

        if (!$event || $event->post_type !== 'etn') {
            return new WP_Error('event_not_found', 'Event not found', ['status' => 404]);
        }

        $loc = $this->normalize_location(get_post_meta($id, 'etn_event_location', true));

        return rest_ensure_response([
            'id'    => (int)$event->ID,
            'title' => $event->post_title,
            'slug'  => $event->post_name,

            // ✅ IMPORTANT : ton Event.dart lit json['description']
            'description'       => wp_kses_post(apply_filters('the_content', $event->post_content)),
            'description_plain' => wp_strip_all_tags($event->post_content),

            'start_date' => (string)get_post_meta($id, 'etn_start_date', true),
            'end_date'   => (string)get_post_meta($id, 'etn_end_date', true),
            'start_time' => (string)get_post_meta($id, 'etn_start_time', true),
            'end_time'   => (string)get_post_meta($id, 'etn_end_time', true),
            'timezone'   => (string)get_post_meta($id, 'event_timezone', true),

            // ✅ Location clean
            'location'     => $loc['text'],
            'location_obj' => $loc['obj'],

            'price'   => (float)get_post_meta($id, '_price', true),
            'is_free' => ((float)get_post_meta($id, '_price', true) <= 0),
            'banner'  => $this->get_event_banner_url($id),

            // ✅ Schedules
            'schedule' => $this->get_schedules_for_event($id),

            // ✅ Speakers (compatible Speaker.fromCustomApiJson)
            'speakers' => $this->get_speakers_for_event($id),
        ]);
    }

    /**
     * ==============================
     * PROGRAM (grouped by date)
     * ==============================
     * Objectif: alimenter ProgramScreen avec un format simple
     */
    public function get_program(WP_REST_Request $request) {

        $order = (string)$request->get_param('order');
        $per_page = max(1, min(200, (int)$request->get_param('per_page')));

        $events = get_posts([
            'post_type'      => 'etn',
            'posts_per_page' => $per_page,
            'post_status'    => 'publish',
            'orderby'        => 'meta_value',
            'meta_key'       => 'etn_start_date',
            'order'          => $order,
        ]);

        $groups = [];

        foreach ($events as $event) {
            $event_id = (int)$event->ID;
            $date = (string)get_post_meta($event_id, 'etn_start_date', true);
            if (empty($date)) continue;

            if (!isset($groups[$date])) {
                $groups[$date] = ['date' => $date, 'events' => []];
            }

            $loc = $this->normalize_location(get_post_meta($event_id, 'etn_event_location', true));

            $groups[$date]['events'][] = [
                'id'       => $event_id,
                'title'    => $event->post_title,
                'location' => $loc['text'],
                'schedule' => $this->get_schedules_for_event($event_id),
            ];
        }

        $dates = array_keys($groups);
        sort($dates);
        if ($order === 'DESC') $dates = array_reverse($dates);

        $days = [];
        $jourIndex = 1;

        foreach ($dates as $date) {

            $daySessions = [];

            foreach ($groups[$date]['events'] as $e) {
                foreach ($e['schedule'] as $s) {

                    // Format volontairement proche de Session.fromCustomApiJson()
                    $daySessions[] = [
                        'id'          => (string)$s['id'],
                        'title'       => (string)$s['title'],
                        'description' => (string)$s['description'],
                        'start_time'  => (string)$s['start_time'],
                        'end_time'    => (string)$s['end_time'],

                        // pour affichage stable
                        'location_name' => (string)$e['location'],

                        // à enrichir si relation réelle dispo
                        'speaker' => null,
                    ];
                }
            }

            $days[] = [
                'id'             => $date,
                'label'          => 'Jour ' . $jourIndex,
                'date_label'     => $date,

                // compat éventuelle côté Flutter
                'schedule_date'  => $date,
                'schedule_title' => 'Jour ' . $jourIndex,
                'sessions'       => $daySessions,
            ];

            $jourIndex++;
        }

        return rest_ensure_response([
            'total' => count($days),
            'data'  => $days,
        ]);
    }

    /**
     * ==============================
     * SCHEDULES HELPERS
     * ==============================
     */
    private function get_schedules_for_event(int $event_id): array {

        $schedules_posts = [];

        // 1) meta_query sur plusieurs clés
        foreach ($this->schedule_event_meta_keys as $meta_key) {
            $found = get_posts([
                'post_type'      => 'etn-schedule',
                'post_status'    => 'publish',
                'posts_per_page' => -1,
                'meta_query'     => [
                    [
                        'key'     => $meta_key,
                        'value'   => $event_id,
                        'compare' => '=',
                    ],
                ],
                'orderby' => 'date',
                'order'   => 'ASC',
            ]);

            if (!empty($found)) {
                $schedules_posts = $found;
                break;
            }
        }

        // 2) fallback: post_parent
        if (empty($schedules_posts)) {
            $found = get_posts([
                'post_type'      => 'etn-schedule',
                'post_status'    => 'publish',
                'posts_per_page' => -1,
                'post_parent'    => $event_id,
                'orderby'        => 'date',
                'order'          => 'ASC',
            ]);
            if (!empty($found)) $schedules_posts = $found;
        }

        if (empty($schedules_posts)) return [];

        $schedule = [];
        foreach ($schedules_posts as $s) {

            $sid = (int)$s->ID;

            $start_time = $this->get_first_meta_value($sid, $this->schedule_time_meta_keys);
            $end_time   = $this->get_first_meta_value($sid, $this->schedule_end_time_meta_keys);

            $schedule[] = [
                'id'          => $sid,
                'title'       => $s->post_title,
                'slug'        => $s->post_name,
                'start_time'  => $start_time,
                'end_time'    => $end_time,
                'description' => wp_strip_all_tags($s->post_content),
                'content_html'=> wp_kses_post(apply_filters('the_content', $s->post_content)),
            ];
        }

        return $schedule;
    }

    private function get_first_meta_value(int $post_id, array $keys): string {
        foreach ($keys as $k) {
            $v = get_post_meta($post_id, $k, true);
            if (!empty($v) && is_string($v)) return $v;
        }
        return '';
    }

    /**
     * ==============================
     * SPEAKERS (list)
     * ==============================
     */
    public function get_speakers(WP_REST_Request $request) {

        $page = max(1, (int)$request->get_param('page'));
        $per_page = max(1, min(200, (int)$request->get_param('per_page')));

        $q = new WP_Query([
            'post_type'      => 'etn-speaker',
            'posts_per_page' => $per_page,
            'paged'          => $page,
            'post_status'    => 'publish',
            'orderby'        => 'date',
            'order'          => 'DESC',
        ]);

        $items = [];
        foreach ($q->posts as $p) {
            $items[] = $this->format_speaker((int)$p->ID, $p);
        }

        return rest_ensure_response([
            'page'       => $page,
            'per_page'   => $per_page,
            'total'      => (int)$q->found_posts,
            'total_page' => (int)$q->max_num_pages,
            'data'       => $items,
        ]);
    }

    /**
     * ==============================
     * SPEAKER DETAIL
     * ==============================
     */
    public function get_speaker_detail(WP_REST_Request $request) {

        $id = (int)$request['id'];
        $p = get_post($id);

        if (!$p || $p->post_type !== 'etn-speaker') {
            return new WP_Error('speaker_not_found', 'Speaker not found', ['status' => 404]);
        }

        $item = $this->format_speaker($id, $p);
        $item['bio_html'] = wp_kses_post(apply_filters('the_content', $p->post_content));

        return rest_ensure_response($item);
    }

    private function format_speaker(int $id, WP_Post $p): array {

        $avatar = null;
        $thumb_id = get_post_thumbnail_id($id);
        if (!empty($thumb_id)) $avatar = wp_get_attachment_url((int)$thumb_id);

        // ✅ compatible Speaker.fromCustomApiJson (name + avatar)
        return [
            'id'     => $id,
            'name'   => $p->post_title,
            'slug'   => $p->post_name,
            'avatar' => $avatar,
            'bio'    => wp_strip_all_tags($p->post_content),
        ];
    }

    /**
     * ==============================
     * SPEAKERS FOR EVENT
     * ==============================
     */
    private function get_speakers_for_event(int $event_id): array {

        $ids = [];

        foreach ($this->event_speaker_meta_keys as $k) {
            $raw = get_post_meta($event_id, $k, true);
            if (empty($raw)) continue;

            $val = maybe_unserialize($raw);

            if (is_array($val)) {
                foreach ($val as $x) {
                    $ids[] = (int)$x;
                }
                break;
            }

            // string "1,2,3"
            if (is_string($val) && strpos($val, ',') !== false) {
                $parts = array_map('trim', explode(',', $val));
                foreach ($parts as $x) $ids[] = (int)$x;
                break;
            }

            // string "123"
            if (is_string($val) && ctype_digit($val)) {
                $ids[] = (int)$val;
                break;
            }
        }

        $ids = array_values(array_unique(array_filter($ids)));
        if (empty($ids)) return [];

        $speakers = [];
        foreach ($ids as $sid) {
            $p = get_post($sid);
            if ($p && $p->post_type === 'etn-speaker' && $p->post_status === 'publish') {
                $speakers[] = $this->format_speaker((int)$sid, $p);
            }
        }

        return $speakers;
    }

    /**
     * ==============================
     * MEDIA LIST
     * ==============================
     */
    public function get_media_list(WP_REST_Request $request) {

        $page = max(1, (int)$request->get_param('page'));
        $per_page = max(1, min(50, (int)$request->get_param('per_page')));
        $order = (string)$request->get_param('order');
        $type = (string)$request->get_param('type'); // all|image|video

        $mime_query = null;
        if ($type === 'image') $mime_query = 'image';
        if ($type === 'video') $mime_query = 'video';

        $args = [
            'post_type'      => 'attachment',
            'post_status'    => 'inherit',
            'posts_per_page' => $per_page,
            'paged'          => $page,
            'orderby'        => 'date',
            'order'          => $order,
        ];

        if (!empty($mime_query)) {
            $args['post_mime_type'] = $mime_query;
        }

        $q = new WP_Query($args);

        $items = [];
        foreach ($q->posts as $p) {
            $items[] = $this->format_media((int)$p->ID, $p);
        }

        return rest_ensure_response([
            'page'       => $page,
            'per_page'   => $per_page,
            'total'      => (int)$q->found_posts,
            'total_page' => (int)$q->max_num_pages,
            'data'       => $items,
        ]);
    }

    /**
     * ==============================
     * MEDIA DETAIL
     * ==============================
     */
    public function get_media_detail(WP_REST_Request $request) {

        $id = (int)$request['id'];
        $p = get_post($id);

        if (!$p || $p->post_type !== 'attachment') {
            return new WP_Error('media_not_found', 'Media not found', ['status' => 404]);
        }

        return rest_ensure_response($this->format_media($id, $p));
    }

    private function format_media(int $id, WP_Post $p): array {

        $mime_type = get_post_mime_type($id) ?: '';
        $is_video = (strpos($mime_type, 'video/') === 0);

        // ✅ Toujours thumbnail (plus stable)
        $thumb_url = null;
        $sizes_try = ['medium_large', 'medium', 'thumbnail', 'full'];

        foreach ($sizes_try as $size) {
            $src = wp_get_attachment_image_src($id, $size);
            if (!empty($src) && !empty($src[0])) {
                $thumb_url = $src[0];
                break;
            }
        }

        if (empty($thumb_url)) {
            $thumb_url = wp_get_attachment_url($id);
        }

        $source_url = wp_get_attachment_url($id);

        // Bonus: image alt (utile pour accessibilité + fallback)
        $alt = get_post_meta($id, '_wp_attachment_image_alt', true);

        return [
            'id'            => $id,
            'title'         => get_the_title($id),
            'date'          => get_post_time('c', true, $p),
            'type'          => $is_video ? 'video' : 'photo',
            'mime_type'     => $mime_type,
            'alt'           => is_string($alt) ? $alt : '',

            // ✅ stable pour affichage
            'thumbnail_url' => $thumb_url,

            // URL originale (peut parfois casser decode si format exotique)
            'source_url'    => $source_url,
        ];
    }

    /**
     * ==============================
     * PAGES (mobile-friendly)
     * ==============================
     */
    public function get_about_page(WP_REST_Request $request) {
        // ⚠️ Mets ici le slug exact de ta page.
        // Si ta page s'appelle "À propos" et que WP l'a générée en "a-propos", change ici.
        return $this->get_page_by_slug('apropos', 'mobile');
    }

    public function get_page(WP_REST_Request $request) {
        $slug = (string)$request->get_param('slug');
        $mode = (string)$request->get_param('mode'); // mobile|raw
        return $this->get_page_by_slug($slug, $mode);
    }

    private function get_page_by_slug(string $slug, string $mode = 'mobile') {

        $slug = sanitize_title($slug);

        $page = get_page_by_path($slug, OBJECT, 'page');
        if (!$page) {
            // fallback: chercher par post_name au cas où
            $found = get_posts([
                'post_type'      => 'page',
                'post_status'    => 'publish',
                'name'           => $slug,
                'posts_per_page' => 1,
            ]);
            if (!empty($found)) {
                $page = $found[0];
            }
        }

        if (!$page || !($page instanceof WP_Post)) {
            return new WP_Error('page_not_found', 'Page not found', ['status' => 404]);
        }

        $page_id = (int)$page->ID;

        $content_raw = (string)$page->post_content;
        $content_html = wp_kses_post(apply_filters('the_content', $content_raw));

        if ($mode === 'mobile') {
            $content_html = $this->cleanup_html_for_mobile($content_html);
        }

        return rest_ensure_response([
            'id'            => $page_id,
            'slug'          => $page->post_name,
            'title'         => get_the_title($page_id),
            'updated_at'    => gmdate('c', strtotime($page->post_modified_gmt ?: 'now')),

            // HtmlWidget-friendly
            'content_html'  => $content_html,

            // text fallback
            'content_plain' => wp_strip_all_tags($content_raw),

            // featured image (stable)
            'featured_image' => $this->get_featured_image_url($page_id),
        ]);
    }

    private function cleanup_html_for_mobile(string $html): string {
        // Nettoyage "générique" (tu peux ajuster avec des patterns spécifiques)
        $patterns = [
            // share widgets
            '/<div[^>]*class="[^"]*xs_social_share_widget[^"]*"[^>]*>.*?<\/div>/is',
            // chips/buttons blocs
            '/<div[^>]*class="[^"]*source-inline-chip-container[^"]*"[^>]*>.*?<\/div>/is',
            '/<button[^>]*class="[^"]*multiple-button[^"]*"[^>]*>.*?<\/button>/is',
            // scripts/iframes (souvent inutiles en mobile app)
            '/<script\b[^>]*>.*?<\/script>/is',
        ];

        foreach ($patterns as $re) {
            $html = preg_replace($re, '', $html) ?? $html;
        }

        return $html;
    }

    private function get_featured_image_url(int $post_id): string {
        $thumb_id = get_post_thumbnail_id($post_id);
        if (!$thumb_id) return '';
        $url = wp_get_attachment_url($thumb_id);
        return $url ? $url : '';
    }

    /**
     * ==============================
     * LOCATION NORMALIZATION
     * ==============================
     * Evite les structures bizarres genre {address:{address:...}}
     */
    private function normalize_location($raw): array {

        $text = 'Lieu à définir';
        $obj = null;

        if (is_string($raw)) {
            $raw = trim($raw);
            if ($raw !== '') $text = $raw;
            return ['text' => $text, 'obj' => $obj];
        }

        if (is_array($raw)) {
            $obj = $raw;

            // ['address' => '...']
            if (!empty($raw['address']) && is_string($raw['address'])) {
                $text = $raw['address'];
                return ['text' => $text, 'obj' => $obj];
            }

            // ['address' => ['address' => '...']]
            if (!empty($raw['address']) && is_array($raw['address']) && !empty($raw['address']['address'])) {
                $text = (string)$raw['address']['address'];
                return ['text' => $text, 'obj' => $obj];
            }
        }

        if (is_object($raw)) {
            $obj = $raw;

            if (isset($raw->address) && is_string($raw->address) && $raw->address !== '') {
                $text = $raw->address;
                return ['text' => $text, 'obj' => $obj];
            }

            if (isset($raw->address) && is_object($raw->address) && isset($raw->address->address)) {
                $text = (string)$raw->address->address;
                return ['text' => $text, 'obj' => $obj];
            }
        }

        return ['text' => $text, 'obj' => $obj];
    }

    /**
     * ==============================
     * BANNER HELPERS
     * ==============================
     */
    private function get_event_banner_url(int $event_id): ?string {

        $banner_id = get_post_meta($event_id, 'event_banner_id', true);
        if (!empty($banner_id)) {
            $url = wp_get_attachment_url((int)$banner_id);
            if (!empty($url)) return $url;
        }

        $thumb_id = get_post_thumbnail_id($event_id);
        if (!empty($thumb_id)) {
            $url = wp_get_attachment_url((int)$thumb_id);
            if (!empty($url)) return $url;
        }

        return null;
    }

    /**
     * ==============================
     * DEBUG (OPTIONNEL)
     * ==============================
     */
    public function debug_schedule_meta(WP_REST_Request $request) {
        $id = (int)$request['id'];
        $p = get_post($id);

        if (!$p || $p->post_type !== 'etn-schedule') {
            return new WP_Error('schedule_not_found', 'Schedule not found', ['status' => 404]);
        }

        return rest_ensure_response([
            'id'   => $id,
            'slug' => $p->post_name,
            'meta' => get_post_meta($id),
        ]);
    }
}

new EventIn_Custom_Api();