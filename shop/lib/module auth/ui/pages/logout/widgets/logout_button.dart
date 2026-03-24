import 'package:flutter/material.dart';

import 'package:shop/module%20auth/ui/core/widgets/default_button.dart';
import 'package:shop/module%20auth/ui/pages/logout/view_models/logout_viewmodel.dart';

class LogoutButton extends StatefulWidget {
  const LogoutButton({
    super.key,
    required this.viewModel,
  });

  final LogoutViewModel viewModel;

  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.logout.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant LogoutButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.logout.removeListener(_onResult);
    widget.viewModel.logout.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.logout.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      text: 'Sign Out',
      onPressed: () => widget.viewModel.logout.execute(),
    );
  }

  void _onResult() {
    if (widget.viewModel.logout.error) {
      widget.viewModel.logout.clearResult();
    }
  }
}
