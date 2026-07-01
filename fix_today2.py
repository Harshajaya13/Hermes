with open("lib/features/today/today_screen.dart", "r") as f:
    content = f.read()

old_onselected = """                                            } else if (value == 'export_hitem') {
                                              try {
                                                final engine = ref.read(exchangeEngineProvider);
                                                final path = await engine.exportItems([item]);
                                                await Share.shareXFiles([XFile(path)], subject: '${item.title} (Hermes)');
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Export failed: $e'), backgroundColor: HermesColors.veritasColor),
                                                  );
                                                }
                                              }
                                            },"""

new_onselected = """                                            } else if (value == 'export_hitem') {
                                              try {
                                                final engine = ref.read(exchangeEngineProvider);
                                                final path = await engine.exportItems([item]);
                                                await Share.shareXFiles([XFile(path)], subject: '${item.title} (Hermes)');
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Export failed: $e'), backgroundColor: HermesColors.veritasColor),
                                                  );
                                                }
                                              }
                                            } else if (value == 'open_url') {
                                              if (item.sourceUrl != null && item.sourceUrl!.isNotEmpty) {
                                                final uri = Uri.parse(item.sourceUrl!);
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(uri);
                                                }
                                              }
                                            },"""

old_itembuilder = """                                            PopupMenuItem(
                                              value: 'export_hitem',
                                              child: Text('Export as .hitem', style: HermesTypography.bodySmall),
                                            ),
                                          ],"""

new_itembuilder = """                                            PopupMenuItem(
                                              value: 'export_hitem',
                                              child: Text('Export as .hitem', style: HermesTypography.bodySmall),
                                            ),
                                            if (item.sourceUrl != null && item.sourceUrl!.isNotEmpty)
                                              PopupMenuItem(
                                                value: 'open_url',
                                                child: Text('Open Original Link', style: HermesTypography.bodySmall.copyWith(color: HermesColors.evolutioGlow)),
                                              ),
                                          ],"""

content = content.replace(old_onselected, new_onselected)
content = content.replace(old_itembuilder, new_itembuilder)

with open("lib/features/today/today_screen.dart", "w") as f:
    f.write(content)
