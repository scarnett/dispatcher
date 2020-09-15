import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

class AppBlocObserver extends BlocObserver {
  Logger logger = Logger();

  @override
  void onEvent(
    Bloc bloc,
    Object event,
  ) {
    logger.i(event);
    super.onEvent(bloc, event);
  }

  @override
  void onChange(
    Cubit cubit,
    Change change,
  ) {
    logger.i(change);
    super.onChange(cubit, change);
  }

  @override
  void onTransition(
    Bloc bloc,
    Transition transition,
  ) {
    logger.i(transition);
    super.onTransition(bloc, transition);
  }

  @override
  void onError(
    Cubit cubit,
    Object error,
    StackTrace stackTrace,
  ) {
    logger.e(error, error, stackTrace);
    super.onError(cubit, error, stackTrace);
  }
}
