    import 'package:flutter_dotenv/flutter_dotenv.dart';

    class ApiService {
   
      final String apiKey = dotenv.env['API_KEY'] ?? 'default_api_key';

    }