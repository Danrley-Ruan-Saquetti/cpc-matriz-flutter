import 'package:flutter/foundation.dart';

enum ViewState { idle, loading, success, error }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  ViewState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  void setState(ViewState value) {
    _state = value;
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _state = ViewState.error;
    notifyListeners();
  }

  Future<bool> run(Future<void> Function() action) async {
    _errorMessage = null;
    setState(ViewState.loading);

    try {
      await action();
      setState(ViewState.success);

      return true;
    } catch (e) {
      setError(_threatError(e));

      return false;
    }
  }

  String _threatError(Object e) {
    final text = e.toString();

    if (text.contains('SocketException') ||
        text.contains('Connection') ||
        text.contains('connect')) {
      return 'Nao foi possivel conectar ao banco de dados. '
          'Verifique as configuracoes em DbConfig.';
    }

    return text.replaceFirst('Exception: ', '');
  }
}
