import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:sona/config/dependency_injection.dart';
import 'package:sona/domain/models/tip.dart';
import 'package:sona/domain/services/tip.dart';
import 'package:sona/ui/widgets/image_builder.dart';
import 'package:sona/ui/widgets/sona_scaffold.dart';

@RoutePage()
class TipDetailsScreen extends StatefulWidget {
  //
  final Tip tip;
  final ValueNotifier<Tip> notifier;

  const TipDetailsScreen({
    super.key,
    required this.tip,
    required this.notifier,
  });

  @override
  State<TipDetailsScreen> createState() => _TipDetailsScreenState();
}

class _TipDetailsScreenState extends State<TipDetailsScreen> {
  final _tipsService = injector.get<TipService>();
  late final ValueNotifier<double> _ratingNotifier;

  @override
  void initState() {
    super.initState();
    _ratingNotifier = ValueNotifier(widget.tip.myRate?.toDouble() ?? 0);
    _ratingNotifier.addListener(_rateTip);
  }

  void _rateTip() async {
    final value = _ratingNotifier.value;
    await _tipsService.rate(widget.tip, value.toInt());
    widget.notifier.value = await _tipsService.find(widget.tip.id);
  }

  @override
  void dispose() {
    _ratingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SonaScaffold(
      actionButton: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: AutoRouter.of(context).back,
      ),
      padding: 16,
      body: ValueListenableBuilder<Tip>(
        valueListenable: widget.notifier,
        builder: (context, tip, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            tip.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MarkdownBody(
                            data: tip.description,
                            styleSheet: MarkdownStyleSheet(textAlign: WrapAlignment.spaceEvenly, p: const TextStyle(fontSize: 15)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ImageBuilder(
                        provider: _tipsService.image(tip),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      'Etiquetas:',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6.0,
                      children: [
                        for (final tag in tip.tags)
                          Chip(
                            label: Text(tag),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<double>(
                      valueListenable: _ratingNotifier,
                      builder: (context, value, child) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Valora este tip',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            RatingStars(
                              axis: Axis.horizontal,
                              value: value,
                              onValueChanged: (newValue) => _ratingNotifier.value = newValue,
                              starCount: 5,
                              starSize: 40,
                              starColor: Colors.amber,
                              animationDuration: const Duration(milliseconds: 100),
                              valueLabelVisibility: false,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _statItem(
                                  label: 'Valoración promedio',
                                  value: tip.averageRate.toStringAsFixed(1),
                                ),
                                const SizedBox(width: 20),
                                _statItem(
                                  label: 'Total valoraciones',
                                  value: tip.totalRate.toString(),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
