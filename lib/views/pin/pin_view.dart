import 'package:dispatcher/extensions/extensions.dart';
import 'package:dispatcher/graphql/client_provider.dart';
import 'package:dispatcher/graphql/user.dart';
import 'package:dispatcher/localization.dart';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/theme.dart';
import 'package:dispatcher/utils/snackbar_utils.dart';
import 'package:dispatcher/views/auth/bloc/bloc.dart';
import 'package:dispatcher/views/pin/bloc/pin_bloc.dart';
import 'package:dispatcher/views/pin/pin_config.dart';
import 'package:dispatcher/views/pin/pin_enums.dart';
import 'package:dispatcher/widgets/form_button.dart';
import 'package:dispatcher/widgets/pin_code.dart';
import 'package:dispatcher/widgets/progress.dart';
import 'package:dispatcher/widgets/simple_appbar.dart';
import 'package:dispatcher/widgets/view_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

// Displays the 'PIN' view
class PINView extends StatelessWidget {
  static Route route() => MaterialPageRoute<void>(builder: (_) => PINView());

  const PINView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
  ) =>
      ClientProvider(
        child: BlocProvider<PINBloc>(
          create: (BuildContext context) => PINBloc()
            ..add(
              LoadUserPIN(
                Provider.of<GraphQLClient>(context, listen: false),
                context.bloc<AuthBloc>().state.firebaseUser,
              ),
            ),
          child: PINPageView(),
        ),
      );
}

class PINPageView extends StatefulWidget {
  PINPageView({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PINPageViewState();
}

class _PINPageViewState extends State<PINPageView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(
    BuildContext context,
  ) =>
      BlocListener<PINBloc, PINState>(
        listener: (
          BuildContext context,
          PINState state,
        ) {
          switch (state.eventType) {
            case PINEventType.RESENDING_VERIFICATION_CODE:
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).resentVerificationCode,
                type: MessageType.SUCCESS,
              )));

              break;

            default:
              break;
          }

          if ((state.verificationCode != null) &&
              (state.verificationCodeVerified != null) &&
              (state.pinCode == null)) {
            if (state.verificationCodeVerified) {
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).validVerificationCode,
                type: MessageType.SUCCESS,
              )));
            } else {
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).invalidVerificationCode,
                type: MessageType.ERROR,
              )));

              context.bloc<PINBloc>().add(ResetVerificationCodeVerified());
            }
          } else if ((state.pinCode != null) && (state.pinCodeSaved != null)) {
            if (state.pinCodeSaved) {
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text:
                    AppLocalizations.of(context).pinCodeUpdateConfirmationText,
                type: MessageType.SUCCESS,
              )));
            } else {
              _scaffoldKey.currentState.showSnackBar(buildSnackBar(Message(
                text: AppLocalizations.of(context).invalidPINCode,
                type: MessageType.ERROR,
              )));

              context.bloc<PINBloc>().add(ResetPINCodeSaved());
            }
          }
        },
        child: BlocBuilder<PINBloc, PINState>(
          builder: (
            BuildContext context,
            PINState state,
          ) =>
              WillPopScope(
            onWillPop: () => _willPopCallback(),
            child: Scaffold(
              key: _scaffoldKey,
              appBar: SimpleAppBar(
                height: 100.0,
              ),
              body: Query(
                options: QueryOptions(
                  documentNode: gql(fetchPINQueryStr),
                  variables: <String, dynamic>{
                    'identifier':
                        context.bloc<AuthBloc>().state.firebaseUser.uid,
                  },
                ),
                builder: (
                  QueryResult result, {
                  Refetch refetch,
                  FetchMore fetchMore,
                }) =>
                    Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        _buildBody(state),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }

  /// Handles the android back button
  Future<bool> _willPopCallback() {
    context.bloc<PINBloc>().add(ClearPIN(context.bloc<AuthBloc>().state.user));
    return Future.value(true);
  }

  /// Builds the pin body
  Widget _buildBody(
    PINState state,
  ) {
    if (state.loaded) {
      if ((state.verificationCodeVerified != null) &&
          state.verificationCodeVerified) {
        return _buildPINCodeForm(state);
      } else if ((state.pinCodeSaved != null) && state.pinCodeSaved) {
        return _buildPINCodeConfirmation();
      } else if ((state.pin == null) ||
          ((state.pin != null) &&
              state.pin.verificationCode.isNullEmptyOrWhitespace)) {
        return _buildSendVerificationCodeForm(state);
      } else if ((state.pin != null) &&
          !state.pin.verificationCode.isNullEmptyOrWhitespace) {
        return _buildCodeVerificationForm(state);
      }
    }

    return ViewMessage();
  }

  /// Builds the 'send verification code' form
  Widget _buildSendVerificationCodeForm(
    PINState state,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).sendPinVerificationCodeText(
                PINConfig.VERIFICATION_CODE_LENGTH,
                PINConfig.VERIFICATION_CODE_EXPIRE_MINUTES,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Text(
            context
                .bloc<AuthBloc>()
                .state
                .user
                .phone
                .toPhoneNumber()
                .phoneNumber,
            style: Theme.of(context).textTheme.headline6,
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: Text(
              AppLocalizations.of(context).enterPhoneNumberDisclaimer,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
              top: 10.0,
            ),
            child: (state.eventType == PINEventType.SENDING_VERIFICATION_CODE)
                ? Progress()
                : FormButton(
                    text: AppLocalizations.of(context).sendCode,
                    onPressed: () => context.bloc<PINBloc>().add(
                          SendVerificationCode(
                            context.bloc<AuthBloc>().state.user,
                            AppLocalizations.of(context),
                          ),
                        ),
                  ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed:
                (state.eventType == PINEventType.SENDING_VERIFICATION_CODE)
                    ? null
                    : _tapCancel,
            textColor: AppTheme.accent,
            textButton: true,
          ),
        ],
      );

  /// Builds the 'code verification' form
  Widget _buildCodeVerificationForm(
    PINState state,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).verifyPinVerificationCodeText(
                  PINConfig.VERIFICATION_CODE_LENGTH),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Container(
            child: PinCodeTextField(
              key: const Key('pinForm_verificationCode_pinCodeField'),
              keyboardType: TextInputType.number,
              maxLength: PINConfig.VERIFICATION_CODE_LENGTH,
              spacerIndex: 0,
              onTextChanged: (text) =>
                  context.bloc<PINBloc>().add(VerificationCodeChanged(text)),
              onDone: (text) =>
                  context.bloc<PINBloc>().add(VerificationCodeChanged(text)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
              top: 10.0,
            ),
            child: (state.eventType == PINEventType.VERIFYING_VERIFICATION_CODE)
                ? Progress()
                : FormButton(
                    text: AppLocalizations.of(context).verifyCode,
                    onPressed: !state.verificationCode.isNullEmptyOrWhitespace
                        ? () => context
                            .bloc<PINBloc>()
                            .add(VerifyVerificationCodeSubmitted(
                              context.bloc<AuthBloc>().state.user,
                            ))
                        : null,
                  ),
          ),
          (state.eventType == PINEventType.RESENDING_VERIFICATION_CODE)
              ? Progress()
              : FormButton(
                  color: Colors.transparent,
                  text: AppLocalizations.of(context).resendCode,
                  onPressed: (state.eventType ==
                          PINEventType.VERIFYING_VERIFICATION_CODE)
                      ? null
                      : () => context.bloc<PINBloc>().add(
                            ResendVerificationCode(
                              context.bloc<AuthBloc>().state.user,
                              AppLocalizations.of(context),
                            ),
                          ),
                  textColor: AppTheme.accent,
                  textButton: true,
                ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed:
                (state.eventType == PINEventType.VERIFYING_VERIFICATION_CODE)
                    ? null
                    : _tapCancel,
            textColor: AppTheme.accent,
            textButton: true,
          ),
        ],
      );

  /// Builds the 'pin code' form
  Widget _buildPINCodeForm(
    PINState state,
  ) =>
      Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).enterPin,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Container(
            child: PinCodeTextField(
              key: const Key('pinForm_pinCode_pinCodeField'),
              keyboardType: TextInputType.number,
              maxLength: PINConfig.PIN_CODE_LENGTH,
              spacerIndex: 0,
              onTextChanged: (text) =>
                  context.bloc<PINBloc>().add(PINCodeChanged(text)),
              onDone: (text) =>
                  context.bloc<PINBloc>().add(PINCodeChanged(text)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 10.0,
              top: 10.0,
            ),
            child: (state.eventType == PINEventType.SAVING_PINCODE)
                ? Progress()
                : FormButton(
                    text: AppLocalizations.of(context).save,
                    onPressed: !state.pinCode.isNullEmptyOrWhitespace
                        ? () => context.bloc<PINBloc>().add(
                            PINSubmitted(context.bloc<AuthBloc>().state.user))
                        : null,
                  ),
          ),
          FormButton(
            color: Colors.transparent,
            text: AppLocalizations.of(context).cancel,
            onPressed: (state.eventType == PINEventType.SAVING_PINCODE)
                ? null
                : _tapCancel,
            textColor: AppTheme.accent,
            textButton: true,
          ),
        ],
      );

  /// Builds the 'pin code confirmation' form
  Widget _buildPINCodeConfirmation() => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              AppLocalizations.of(context).pinCodeUpdateConfirmationText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: FormButton(
              text: AppLocalizations.of(context).ok,
              onPressed: _tapCancel,
            ),
          ),
        ],
      );

  void _tapCancel() {
    context.bloc<PINBloc>().add(ClearPIN(context.bloc<AuthBloc>().state.user));
    Navigator.pop(context);
  }
}
