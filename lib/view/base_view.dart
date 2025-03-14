import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tetris_app/theme/component/circular_indicator.dart';
import 'package:tetris_app/view/base_view_model.dart';

class BaseView<T extends BaseViewModel> extends StatelessWidget {
  const BaseView({
    super.key,
    required this.viewModel,
    required this.builder,
  });

  final T viewModel;
  final Widget Function(BuildContext context, T viewModel) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => viewModel,
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<T>();
          return CircularIndicator(
            isBusy: viewModel.state.isBusy,
            child: builder(context, viewModel),
          );
        },
      ),
    );
  }
}
