import 'package:flutter/material.dart';
import '../../../../../models/agent.dart';
import '../../../../../services/order_service.dart';

class ServiceDetailsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final int? selectedAgentId;
  final int? selectedLocationId;
  final List<Agent> agents;
  final Function(int) onAgentChanged;
  final Function(int) onLocationChanged;

  const ServiceDetailsStep({
    super.key,
    required this.formKey,
    required this.selectedAgentId,
    required this.selectedLocationId,
    required this.agents,
    required this.onAgentChanged,
    required this.onLocationChanged,
  });

  @override
  State<ServiceDetailsStep> createState() => _ServiceDetailsStepState();
}

class _ServiceDetailsStepState extends State<ServiceDetailsStep> {
  List<AgentLocation> _locations = [];
  bool _loadingLocations = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedAgentId != null) {
      _loadLocations(widget.selectedAgentId!);
    }
  }

  @override
  void didUpdateWidget(ServiceDetailsStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAgentId != widget.selectedAgentId && widget.selectedAgentId != null) {
      _loadLocations(widget.selectedAgentId!);
    }
  }

  Future<void> _loadLocations(int agentId) async {
    setState(() {
      _loadingLocations = true;
    });

    try {
      final locations = await OrderService.getAgentLocations(agentId);
      setState(() {
        _locations = locations;
        _loadingLocations = false;
      });
    } catch (e) {
      setState(() {
        _locations = [];
        _loadingLocations = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load locations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Service Details'),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: widget.selectedAgentId,
              decoration: const InputDecoration(
                labelText: 'Collecting Agent',
                prefixIcon: Icon(Icons.person_pin_circle_outlined),
                border: OutlineInputBorder(),
              ),
              items: widget.agents.map((agent) {
                return DropdownMenuItem(
                  value: agent.id,
                  child: Text(
                    '${agent.name})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onAgentChanged(value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: widget.selectedLocationId,
              decoration: InputDecoration(
                labelText: 'Collection Location',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
                suffixIcon: _loadingLocations 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location.id,
                  child: Text(
                    location.location,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: _loadingLocations ? null : (value) {
                if (value != null) {
                  widget.onLocationChanged(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}