import 'package:flutter/foundation.dart';
import '../models/box_size.dart';
import '../models/agent.dart';
import '../models/order_request.dart';
import '../models/order_response.dart';
import '../models/order.dart';
import '../models/dashboard_data.dart';
import 'api_service.dart';

class OrderService {
  // Get available box sizes
  static Future<List<BoxSize>> getBoxSizes() async {
    try {
      final response = await ApiService.get('/api/v1/getBoxSizes');
      debugPrint('BoxSizes API response: $response');

      if (response['success'] == true && response['data'] != null) {
        debugPrint('BoxSizes dataaaaaa: ${response['data']}');
        List<BoxSize> boxSizes = [];
        for (var item in response['data']) {
          boxSizes.add(BoxSize.fromJson(item));
        }
        return boxSizes;
      } else {
        throw Exception(response['message'] ?? 'Failed to get box sizes');
      }
    } on ApiException catch (e) {
      debugPrint('BoxSizes API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('BoxSizes error: $e');
      throw Exception('Failed to load box sizes: ${e.toString()}');
    }
  }

  // Get available agents
  static Future<List<Agent>> getAgents() async {
    try {
      final response = await ApiService.get('/api/v1/getAgents');
      debugPrint('Agents API response: $response');

      if (response['success'] == true && response['data'] != null) {
        List<Agent> agents = [];
        for (var item in response['data']) {
          agents.add(Agent.fromJson(item));
        }
        return agents;
      } else {
        throw Exception(response['message'] ?? 'Failed to get agents');
      }
    } on ApiException catch (e) {
      debugPrint('Agents API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Agents error: $e');
      throw Exception('Failed to load agents: ${e.toString()}');
    }
  }

  // Get agent locations by agent ID
  static Future<List<AgentLocation>> getAgentLocations(int agentId) async {
    try {
      final response = await ApiService.get(
        '/api/v1/getAgentLocations?agent_id=$agentId',
      );
      debugPrint('Agent Locations API response: $response');

      if (response['success'] == true && response['locations'] != null) {
        List<AgentLocation> locations = [];
        for (var item in response['locations']) {
          locations.add(AgentLocation.fromJson(item));
        }
        return locations;
      } else {
        throw Exception(response['message'] ?? 'Failed to get agent locations');
      }
    } on ApiException catch (e) {
      debugPrint('Agent Locations API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Agent Locations error: $e');
      throw Exception('Failed to load agent locations: ${e.toString()}');
    }
  }

  // Calculate price for custom box dimensions
  static Future<Map<String, dynamic>> calculatePrice({
    required double width,
    required double height,
    required double length,
  }) async {
    try {
      final formData = <String, String>{
        'width': width.toString(),
        'height': height.toString(),
        'length': length.toString(),
      };

      debugPrint('Calculating price with formData: $formData');

      final response = await ApiService.postMultipart('/api/v1/orders/calPrice', formData);
      debugPrint('Calculate price API response: $response');

      return response;
    } on ApiException catch (e) {
      debugPrint('Calculate price API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Calculate price error: $e');
      throw Exception('Failed to calculate price: ${e.toString()}');
    }
  }

  // Add package to an existing order
  static Future<Map<String, dynamic>> addPackage({
    required String reference,
    required String packageType,
    required String packageDescription,
    required int boxSizeId,
    required double packagePrice,
    required bool isCustomSize,
    double? customWidth,
    double? customHeight,
    double? customLength,
    double? customWeight,
    double? customPrice,
    double? extraFee,
  }) async {
    try {
      final formData = <String, String>{
        'reference': reference,
        'package_type': packageType,
        'package_description': packageDescription,
        'box_size': boxSizeId.toString(),
        'package_price': packagePrice.toString(),
        'is_custom_size': isCustomSize ? '1' : '0',
        'action': 'add_package',
      };

      if (isCustomSize) {
        formData['custom_width'] = customWidth?.toString() ?? '0';
        formData['custom_height'] = customHeight?.toString() ?? '0';
        formData['custom_length'] = customLength?.toString() ?? '0';
        formData['custom_weight'] = customWeight?.toString() ?? '0';
        formData['custom_price'] = customPrice?.toString() ?? '0';
        if (extraFee != null) {
          formData['extra_fee'] = extraFee.toString();
        }
      }

      debugPrint('Adding package with formData: $formData');

      final response = await ApiService.postMultipart('/api/v1/orders/addPackage', formData);
      debugPrint('Add package API response: $response');

      return response;
    } on ApiException catch (e) {
      debugPrint('Add package API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Add package error: $e');
      throw Exception('Failed to add package: ${e.toString()}');
    }
  }

  // Create new order
  static Future<OrderResponse> createOrder(OrderRequest orderRequest) async {
    try {
      // Prepare form data for multipart request
      final formData = orderRequest.toFormData();

      debugPrint('Creating order with data: $formData');

      Map<String, dynamic> response;

      // Check if we have passport images to upload
      if (orderRequest.senderPassportImage != null ||
          orderRequest.receiverPassportImage != null) {
        // Use multipart request for file uploads
        if (orderRequest.senderPassportImage != null) {
          response = await ApiService.postMultipart(
            '/api/v1/orders/create',
            formData,
            file: orderRequest.senderPassportImage,
            fileField: 'passport_image',
          );
        } else {
          response = await ApiService.postMultipart(
            '/api/v1/orders/create',
            formData,
            file: orderRequest.receiverPassportImage,
            fileField: 'consignee_passport_image',
          );
        }
      } else {
        // Use regular POST request
        response = await ApiService.post(
          '/api/v1/orders/create',
          orderRequest.toJson(),
        );
      }

      debugPrint('Create order API response: $response');
      return OrderResponse.fromJson(response);
    } on ApiException catch (e) {
      debugPrint('Create order API error: $e');
      return OrderResponse.error(e.userMessage, errors: e.errors);
    } catch (e) {
      debugPrint('Create order error: $e');
      return OrderResponse.error('Failed to create order: ${e.toString()}');
    }
  }

  // Calculate package price based on dimensions
  // static Future<Map<String, dynamic>> calculatePrice(
  //   double width,
  //   double height,
  //   double length,
  // ) async {
  //   try {
  //     final response = await ApiService.post('cal_price', {
  //       'width': width,
  //       'height': height,
  //       'length': length,
  //     });

  //     debugPrint('Calculate price API response: $response');

  //     if (response['status'] == 200) {
  //       return {'volume': response['volume'], 'price': response['price']};
  //     } else {
  //       throw Exception(response['message'] ?? 'Failed to calculate price');
  //     }
  //   } on ApiException catch (e) {
  //     debugPrint('Calculate price API error: $e');
  //     throw Exception(e.userMessage);
  //   } catch (e) {
  //     debugPrint('Calculate price error: $e');
  //     throw Exception('Failed to calculate price: ${e.toString()}');
  //   }
  // }

  // Get order history
  static Future<List<Order>> getOrderHistory() async {
    try {
      final formData = <String, String>{
        // Add any required parameters here
      };

      debugPrint('Getting order history with formData: $formData');

      final response = await ApiService.postMultipart('/api/v1/orders/searchWaybillHistory', formData);
      debugPrint('Order history API response: $response');

      if (response['success'] == true && response['data'] != null) {
        List<Order> orders = [];
        for (var item in response['data']) {
          orders.add(Order.fromJson(item));
        }
        return orders;
      } else {
        throw Exception(response['message'] ?? 'Failed to get order history');
      }
    } on ApiException catch (e) {
      debugPrint('Order history API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Order history error: $e');
      throw Exception('Failed to load order history: ${e.toString()}');
    }
  }

  // Calculate package price based on weight
  static Future<Map<String, dynamic>> calculateWeightPrice(
    double weight,
  ) async {
    try {
      final response = await ApiService.post(
        '/master_files/exsisting_waybill/cal_weight_price',
        {'weight': weight},
      );

      debugPrint('Calculate weight price API response: $response');

      if (response['status'] == 200) {
        return {'price': response['price'], 'message': response['message']};
      } else {
        throw Exception(
          response['message'] ?? 'Failed to calculate weight price',
        );
      }
    } on ApiException catch (e) {
      debugPrint('Calculate weight price API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Calculate weight price error: $e');
      throw Exception('Failed to calculate weight price: ${e.toString()}');
    }
  }

  // Get dashboard data
  static Future<DashboardData> getMobileDashboardData() async {
    try {
      final response = await ApiService.get('/api/v1/orders/getMobileDashboardData');
      debugPrint('Dashboard data API response: $response');

      if (response['success'] == true) {
        debugPrint('Dashboard data: ${response}');
        return DashboardData.fromJson(response);
      } else {
        throw Exception(response['message'] ?? 'Failed to get dashboard data');
      }
    } on ApiException catch (e) {
      debugPrint('Dashboard data API error: $e');
      throw Exception(e.userMessage);
    } catch (e) {
      debugPrint('Dashboard data error: $e');
      throw Exception('Failed to load dashboard data: ${e.toString()}');
    }
  }
}
