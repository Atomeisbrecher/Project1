import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gap/flutter_gap.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'package:shop/core/misc/app_regex.dart';
import 'package:shop/module%20auth/ui/pages/login/widgets/form_field_text.dart';
import 'package:shop/module%20auth/ui/pages/sign_in/view_models/sign_in_viewmodel.dart';
import 'package:shop/routing/routes.dart';

import 'package:shop/core/misc/extensions.dart';
import 'package:shop/module%20auth/ui/core/widgets/app_text_button.dart';
import 'package:shop/module%20auth/ui/pages/sign_in/widgets/password_validation.dart';

//@immutable
class EmailAndPassword extends StatefulWidget {
  final bool? isSignInPage;
  final bool? isPasswordPage;
  final SignInViewModel? viewModel;
  late GoogleSignInAccount? googleUser;
  late OAuthCredential? credential;

  EmailAndPassword({
    super.key,
    this.isSignInPage,
    this.isPasswordPage,
    this.googleUser,
    this.credential,
    this.viewModel,
  });

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  bool isObscureText = true;
  bool hasMinLength = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  final passwordFocuseNode = FocusNode();
  final passwordConfirmationFocuseNode = FocusNode();
  
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    passwordFocuseNode.dispose();
    passwordConfirmationFocuseNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          usernameField(),
          emailField(),
          passwordField(),
          Gap(18.h),
          passwordConfirmationField(),
          forgetPasswordTextButton(),
          Gap(10.h),
          PasswordValidations(
            hasMinLength: hasMinLength,
          ),
          Gap(20.h),
          loginOrSignInOrPasswordButton(context),
        ],
      ),
    );
  }

  void checkForPasswordConfirmationFocused() {
    passwordConfirmationFocuseNode.addListener(() {
      if (passwordConfirmationFocuseNode.hasFocus && isObscureText) {
      } else if (!passwordConfirmationFocuseNode.hasFocus && isObscureText) {
      }
    });
  }

  void checkForPasswordFocused() {
    passwordFocuseNode.addListener(() {
      if (passwordFocuseNode.hasFocus && isObscureText) {
      } else if (!passwordFocuseNode.hasFocus && isObscureText) {
      }
    });
  }

  Widget emailField() {
    if (widget.isPasswordPage == null) {
      return Column(
        children: [
          FormFieldText(
            hint: 'Email',
            validator: (value) {
              String email = (value ?? '').trim();

              emailController.text = email;

              if (email.isEmpty) {
                return 'Please enter an email address';
              }

              if (!AppRegex.isEmailValid(email)) {
                return 'Please enter a valid email address';
              }
            },
            controller: emailController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget forgetPasswordTextButton() {
    if (widget.isSignInPage == null && widget.isPasswordPage == null) {
      return TextButton(
        onPressed: () {
          context.pushNamed(Routes.restoreScreen);
        },
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'forget password?',
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    setupPasswordControllerListener();
    checkForPasswordFocused();
    checkForPasswordConfirmationFocused();
  }

  AppTextButton loginButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Login",
      textStyle: TextStyle(
        fontSize: 14,
        color: Colors.white,
      ),
      onPressed: () async {
        passwordFocuseNode.unfocus();
        // if (formKey.currentState!.validate()) {
        //   context.read<AuthCubit>().signInWithEmail(
        //         emailController.text,
        //         passwordController.text,
        //       );
        // }
      },
    );
  }

  dynamic loginOrSignInOrPasswordButton(BuildContext context) {
    if (widget.isSignInPage == true) {
      return signInButton(context);
    }
    if (widget.isSignInPage == null && widget.isPasswordPage == null) {
      return loginButton(context);
    }
    if (widget.isPasswordPage == true) {
      return passwordButton(context);
    }
  }

  Widget usernameField() {
    if (widget.isSignInPage == true) {
      return Column(
        children: [
          FormFieldText(
            hint: 'Username',
            validator: (value) {
              String name = (value ?? '').trim();
              nameController.text = name;
              if (name.isEmpty) {
                return 'Please enter a valid username';
              }
            },
            controller: nameController,
          ),
          Gap(18.h),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  AppTextButton passwordButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Create Password",
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight(600),
      ),
      onPressed: () async {
        passwordFocuseNode.unfocus();
        passwordConfirmationFocuseNode.unfocus();
        // if (formKey.currentState!.validate()) {
        //   context.read<AuthCubit>().createAccountAndLinkGoogleAccount(
        //         nameController.text,
        //         passwordController.text,
        //         widget.googleUser!,
        //         widget.credential!,
        //       );
        // }
      },
    );
  }

  Widget passwordConfirmationField() {
    if (widget.isSignInPage == true || widget.isPasswordPage == true) {
      return FormFieldText(
        focusNode: passwordConfirmationFocuseNode,
        controller: passwordConfirmationController,
        hint: 'Password Confirmation',
        isObscureText: isObscureText,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              if (isObscureText) {
                isObscureText = false;
              } else {
                isObscureText = true;
              }
            });
          },
          child: Icon(
            isObscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
        validator: (value) {
          if (value != passwordController.text) {
            return 'Enter a matched passwords';
          }
          if (value == null ||
              value.isEmpty ||
              !AppRegex.isPasswordValid(value)) {
            return 'Please enter a valid password';
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  FormFieldText passwordField() {
    return FormFieldText(
      focusNode: passwordFocuseNode,
      controller: passwordController,
      hint: 'Password',
      isObscureText: isObscureText,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            if (isObscureText) {
              isObscureText = false;
            } else {
              isObscureText = true;
            }
          });
        },
        child: Icon(
          isObscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
      ),
      validator: (value) {
        if (value == null ||
            value.isEmpty ||
            !AppRegex.isPasswordValid(value)) {
          return 'Please enter a valid password';
        }
      },
    );
  }

  void setupPasswordControllerListener() {
    passwordController.addListener(() {
      setState(() {
        hasMinLength = AppRegex.isPasswordValid(passwordController.text);
      });
    });
  }

  AppTextButton signInButton(BuildContext context) {
    return AppTextButton(
      buttonText: "Create Account",
      textStyle: TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight(600)
      ),
      onPressed: () async {
        passwordFocuseNode.unfocus();
        passwordConfirmationFocuseNode.unfocus();
        if (formKey.currentState!.validate()) {
          await widget.viewModel!.signIn.execute(
            (nameController.value.text,
            emailController.value.text,
            passwordController.value.text),
          );
        }
      },
    );
  }
}