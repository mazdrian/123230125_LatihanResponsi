import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String type;
  final String title;

  const DetailScreen({
    super.key,
    required this.id,
    required this.type,
    required this.title,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Article> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.fetchDetail(widget.type, widget.id);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Article>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.black),
                  const SizedBox(height: 16),
                  Text('Gagal memuat detail:\n${snapshot.error}',
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final article = snapshot.data!;
          return _buildDetail(article);
        },
      ),
      floatingActionButton: FutureBuilder<Article>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          final article = snapshot.data!;
          return FloatingActionButton.extended(
            onPressed: () => _launchUrl(article.url),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Lihat Selengkapnya'),
          );
        },
      ),
    );
  }

  Widget _buildDetail(Article article) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          if (article.imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: article.imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 220,
                color: Colors.grey[100],
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                ),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey[100],
                child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            )
          else
            Container(
              height: 220,
              color: Colors.grey[100],
              child: const Center(
                child: Icon(Icons.image, size: 60, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // News site
                if (article.newsSite.isNotEmpty)
                  Text(
                    article.newsSite,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                // Date
                if (article.publishedAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    article.formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),

                // Summary
                if (article.summary.isNotEmpty)
                  Text(
                    article.summary,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
