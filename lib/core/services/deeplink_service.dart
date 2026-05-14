import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Handles incoming deeplinks:
/// thewedge://poll/<pollId>          — open a specific poll
/// thewedge://live?pollId=<id>       — open poll from a YouTube live share
/// https://thewedge.app/polls/<id>   — universal link (same behaviour)
class DeeplinkService {
  final AppLinks _appLinks = AppLinks();

  void initialize(GoRouter router) {
    // Handle cold-start link (app opened via link while closed)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleUri(uri, router);
    });

    // Handle warm links (app already running)
    _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, router),
      onError: (err) => debugPrint('Deeplink error: $err'),
    );
  }

  void _handleUri(Uri uri, GoRouter router) {
    debugPrint('Deeplink received: $uri');

    // thewedge://poll/<pollId>  OR  thewedge://live?pollId=<id>
    if (uri.scheme == 'thewedge') {
      if (uri.host == 'poll' && uri.pathSegments.isNotEmpty) {
        final pollId = uri.pathSegments.first;
        router.push('/polls/$pollId');
      } else if (uri.host == 'live') {
        final pollId = uri.queryParameters['pollId'];
        if (pollId != null) router.push('/polls/$pollId');
      }
      return;
    }

    // Universal links: https://thewedge.app/polls/<pollId>
    if ((uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'polls') {
      final pollId = uri.pathSegments[1];
      router.push('/polls/$pollId');
    }
  }
}
