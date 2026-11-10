/// Konfigurasi URL dan Endpoint API Backend (Laravel AuthController & Warehouse Services)
abstract final class ApiEndpoints {
  /// IP Host default pengembangan lokal (PC/Laptop Server Laravel)
  static const String defaultHost = '192.168.1.127';

  /// Port default server Laravel artisan (`php artisan serve --host=0.0.0.0 --port=8000`)
  static const int defaultPort = 8000;

  /// Prefix API Laravel
  static const String apiPrefix = '/api';

  /// Mendukung override via `--dart-define=API_URL=http://192.168.1.127:8000/api`
  static const String _envApiUrl = String.fromEnvironment('API_URL');

  /// Base URL API default:
  /// 1. Jika `--dart-define=API_URL=...` diberikan, gunakan nilai tersebut.
  /// 2. Jika Web, gunakan host `192.168.1.127:8000` (atau localhost).
  /// 3. Jika Android Emulator, dapat mengarah ke host `192.168.1.127:8000` (LAN) atau `10.0.2.2:8000`.
  /// 4. Default: `http://192.168.1.127:8000/api`
  static String get defaultBaseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }

    // Mengutamakan IP LAN 192.168.1.127 agar perangkat fisik dan emulator dapat terhubung
    return 'http://$defaultHost:$defaultPort$apiPrefix';
  }

  /// URL alternatif untuk Android Emulator jika diperlukan loopback lokal
  static String get emulatorBaseUrl => 'http://10.0.2.2:$defaultPort$apiPrefix';

  /// URL alternatif untuk localhost (Windows Desktop / Web lokal)
  static String get localhostBaseUrl => 'http://127.0.0.1:$defaultPort$apiPrefix';

  // ==========================================
  // Endpoint Autentikasi (AuthController.php)
  // ==========================================
  static const String login = '/login';
  static const String me = '/me';
  static const String logout = '/logout';

  // ==========================================
  // Endpoint Product Serial Number (ProductSnController.php)
  // ==========================================
  static const String productSn = '/product-sn';
  static const String productSnScan = '/product-sn/scan';
  static const String productSnUpdateLocation = '/product-sn/update-location';
  static String productSnDetail(int id) => '/product-sn/$id';

  // ==========================================
  // Endpoint Product Lokasi (ProductLokasiController.php)
  // ==========================================
  static const String productLokasi = '/product-lokasi';
  static const String productLokasiScan = '/product-lokasi/scan';
  static String productLokasiDetail(int id) => '/product-lokasi/$id';

  // ==========================================
  // Endpoint Master Gudang (GudangController.php)
  // ==========================================
  static const String gudang = '/gudang';
  static String gudangDetail(int id) => '/gudang/$id';
  static String gudangLokasi(int id) => '/gudang/$id/lokasi';

  // ==========================================
  // Endpoint Modul Transaksi Warehouse
  // ==========================================
  static const String transactions = '/transactions';
  static String transactionDetail(String id) => '/transactions/$id';
  static String transactionScan(String id) => '/transactions/$id/scan';
  static String transactionComplete(String id) => '/transactions/$id/complete';

  // ==========================================
  // Endpoint Modul Tracker & Opname
  // ==========================================
  static const String tracker = '/tracker';
  static const String opname = '/opname';
  static const String inventory = '/inventory';
}
