// Domain Entities
export 'domain/entities/machine_item.dart';
export 'domain/entities/scan_result.dart';
export 'domain/entities/warehouse_transaction.dart';

// Domain Repositories & Use Cases
export 'domain/repositories/transaction_repository.dart';
export 'domain/usecases/complete_transaction_usecase.dart';
export 'domain/usecases/create_transaction_usecase.dart';
export 'domain/usecases/get_transactions_usecase.dart';
export 'domain/usecases/process_machine_scan_usecase.dart';

// Data Layer
export 'data/datasources/transaction_remote_data_source.dart';
export 'data/models/machine_item_model.dart';
export 'data/models/warehouse_transaction_model.dart';
export 'data/repositories/transaction_repository_impl.dart';

// Presentation Layer - BLoC
export 'presentation/bloc/transaction_bloc.dart';
export 'presentation/bloc/transaction_event.dart';
export 'presentation/bloc/transaction_state.dart';

// Presentation Layer - Widgets
export 'presentation/widgets/camera_scanner_view.dart';
export 'presentation/widgets/machine_item_tile.dart';
export 'presentation/widgets/transaction_card.dart';

// Presentation Layer - Pages
export 'presentation/pages/scanner_page.dart';
export 'presentation/pages/transaction_detail_page.dart';
export 'presentation/pages/transaction_list_page.dart';

