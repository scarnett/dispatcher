import 'package:dispatcher/views/home/bloc/home_bloc.dart';
import 'package:dispatcher/views/home/bloc/home_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatefulWidget {
  DashboardView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocBuilder<HomeBloc, HomeState>(
        builder: (
          BuildContext context,
          HomeState state,
        ) =>
            _buildContent(state),
      );

  /// Builds the content
  Widget _buildContent(
    HomeState state,
  ) =>
      Container();
}
