import 'dart:developer';

void showLog({required String msg}) {
  log('\x1B[32m$msg\x1B[0m');
}
