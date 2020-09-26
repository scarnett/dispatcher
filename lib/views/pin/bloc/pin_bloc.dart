import 'package:dispatcher/graphql/service.dart';
import 'package:dispatcher/views/pin/bloc/pin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class PINBloc extends Bloc<PINEvent, PINState> {
  GraphQLService _service;
  Logger _logger = Logger();

  PINBloc() : super(null);

  @override
  Stream<PINState> mapEventToState(
    PINEvent event,
  ) async* {
    if (event is FetchPINData) {}
  }
}
