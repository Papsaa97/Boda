import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Chyba, která znamená „bez připojení“ (zkusí se později), ne chybu
/// serveru.
bool isNetworkError(Object error) =>
    error is SocketException ||
    error is TimeoutException ||
    error is HandshakeException ||
    error is AuthRetryableFetchException ||
    // package:http ClientException (bez přímé závislosti na balíčku).
    error.runtimeType.toString() == 'ClientException';
