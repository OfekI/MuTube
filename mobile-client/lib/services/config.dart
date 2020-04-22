import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mutube/models/models.dart';

class ConfigUtils {
  static Map<String, dynamic> mergeJson({
    Map<String, dynamic> base,
    Map<String, dynamic> update,
  }) {
    final result = Map.of(base);
    update.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          result[key] is Map<String, dynamic>) {
        result[key] = mergeJson(base: result[key], update: value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  static Map<String, dynamic> parseConfig(
    Map<String, dynamic> json, {
    List<String> keys = const [],
  }) {
    if (json.containsKey('base') && json['base'] is! Map<String, dynamic>) {
      throw ArgumentError.value(json, 'parseConfig',
          "Value of key 'base' must be of type Map<String, dynamic>");
    }

    return {
      for (var key in [...json.keys, ...keys])
        if (key != 'base' &&
            (keys.contains(key) || json[key] is Map<String, dynamic>))
          key: parseConfig(
            mergeJson(
              base: json['base'] ?? {},
              update: json[key] ?? {},
            ),
          )
        else if (key != 'base')
          key: json[key],
    };
  }

  static Future<AppConfig> forEnvironment(
    String env, [
    String testConfig,
  ]) async {
    env = env ?? 'dev';

    final contents = testConfig != null
        ? testConfig
        : await rootBundle.loadString(
            'assets/config.json',
          );

    final config = parseConfig(jsonDecode(contents), keys: [env])[env];

    return AppConfig.fromJson(config);
  }
}

// class GraphQLProviderConfig extends StatelessWidget {
//   GraphQLProviderConfig({this.child});

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthCredentialModel>(
//         builder: (context, credentialModel, child) {
//           final HttpLink httpLink = HttpLink(
//             // uri: 'http://127.0.0.1:5000/graphql',
//             uri: 'http://10.0.0.15:5000/graphql',
//           );
//           final AuthLink authLink = AuthLink(
//             getToken: () => (credentialModel.credential as GoogleAuthCredential)
//                 .accessToken,
//           );
//           final Link link = authLink.concat(httpLink);
//           return GraphQLProvider(
//             client: ValueNotifier(
//               GraphQLClient(
//                 link: link,
//                 cache:
//                     OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
//               ),
//             ),
//             child: child,
//           );
//         },
//         child: child);
//   }
// }
