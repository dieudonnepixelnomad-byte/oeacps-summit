import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:summitoeacp/data/wordpress_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../widgets/app_image.dart';
import '../../models/news.dart';
import '../theme/app_theme.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class NewsDetailScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailScreen({super.key, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  NewsArticle? _article;
  bool _isLoading = true;
  String? _lastLang;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(context).currentLanguageCode;
    if (_lastLang != lang) {
      _lastLang = lang;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    final lang =
        _lastLang ??
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).currentLanguageCode;

    // Try to fetch from API first if it looks like a WP ID (numeric)
    if (int.tryParse(widget.newsId) != null) {
      developer.log(
        'Fetching article from API with ID: ${widget.newsId} (lang: $lang)',
      );

      try {
        final article = await context.read<WordpressService>().getNewsArticle(
          widget.newsId,
          lang: lang,
        );

        if (article != null) {
          if (mounted) {
            setState(() {
              _article = article;
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('Error fetching article: $e');
      }
    }

    // Fallback to list search (cache)
    if (!mounted) return;
    final news = await context.read<WordpressService>().getNews(lang: lang);
    try {
      final article = news.firstWhere((n) => n.id == widget.newsId);
      if (mounted) {
        setState(() {
          _article = article;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // If we have an article from the previous load (e.g. language switch), keep it or null?
          // Here we set to null if not found
          _article = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_article == null) {
      return Scaffold(
        body: Center(child: Text(l10n.translate('article_not_found'))),
      );
    }

    final article = _article!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: AppImage(article.heroImageUrl, fit: BoxFit.cover),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;
                  SharePlus.instance.share(
                    ShareParams(
                      text:
                          '${article.title}\n\n${l10n.translate('share_message_suffix')}',
                      sharePositionOrigin:
                          box!.localToGlobal(Offset.zero) & box.size,
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat(
                          'd MMMM yyyy',
                          l10n.locale.toString(),
                        ).format(article.date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  HtmlWidget(
                    article.content,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (article.quoteText != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: const Border(
                          left: BorderSide(
                            color: AppTheme.accentColor,
                            width: 4,
                          ),
                        ),
                        color: Colors.grey.shade50,
                      ),
                      child: Text(
                        article.quoteText!,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
