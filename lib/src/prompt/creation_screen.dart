import 'package:ai_project/src/blocs/prompt/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/l10n/app_localizations.dart';

class CreationScreen extends StatefulWidget {
  const CreationScreen({super.key});

  @override
  State<CreationScreen> createState() => _CreationScreenState();
}

class _CreationScreenState extends State<CreationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreationBloc, CreationState>(
      listener: (context, state) {
        if (state is CreationChatActive) {
          _scrollToBottom();
        } else if (state is CreationSuccess) {
          context.replace('/path/${state.pathId}');
        } else if (state is CreationFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        final bool isLoadingFinal = state is CreationLoading;
        List<ChatMessage> messages = [];
        bool isTyping = false;
        bool canGenerate = false;

        if (state is CreationChatActive) {
          messages = state.messages;
          isTyping = state.isTyping;
          canGenerate = state.canGenerate;
        }

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.promptPlanYourPath),
                actions: [
                  if (canGenerate && !isLoadingFinal)
                    TextButton.icon(
                      onPressed: () =>
                          context.read<CreationBloc>().add(FinalizePath()),
                      icon: const Icon(Icons.check_circle),
                      label: Text(
                        AppLocalizations.of(context)!.promptBuildPath,
                      ),
                    ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && isTyping) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final msg = messages[index];
                        return Align(
                          alignment: msg.isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: msg.isUser
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Input Area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !isTyping && !isLoadingFinal,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(
                                  context,
                                )!.promptTypeResponse,
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (text) {
                                if (text.trim().isNotEmpty) {
                                  context.read<CreationBloc>().add(
                                    SendMessage(text),
                                  );
                                  _controller.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            color: Theme.of(context).colorScheme.primary,
                            onPressed: isTyping || isLoadingFinal
                                ? null
                                : () {
                                    final text = _controller.text.trim();
                                    if (text.isNotEmpty) {
                                      context.read<CreationBloc>().add(
                                        SendMessage(text),
                                      );
                                      _controller.clear();
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading Overlay for Final Generation
            if (isLoadingFinal)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)!.promptGeneratingPath,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
