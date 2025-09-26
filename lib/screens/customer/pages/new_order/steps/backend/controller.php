<?php

namespace App\Controllers\MasterFiles;

use App\Controllers\BaseController;
use App\Controllers\OrderStatus;
use App\Libraries\CalBoxPrice;
use App\Libraries\MenuLoader;
use App\Libraries\OrderDetails;
use App\Models\BoxSizesModel;
use App\Models\COBModel;
use App\Models\ConformedOrderModel;
use App\Models\CustomerModel;
use App\Models\CustomerPackgesModel;
use App\Models\OrderReference;
use App\Models\OrderReferenceModel;
use App\Models\PickupRequestModel;
use App\Models\StaffMemberModel;
use App\Models\SupplierModel;
use App\Models\AccountNumbersModel;
use App\Models\AccountPostingModel;
use App\Models\AgentLocationModel;
use App\Models\PackageExtraFeeModel;
use CodeIgniter\API\ResponseTrait;

class PickupRequestController extends BaseController

{

    use ResponseTrait;

    public function __construct()
    {
        date_default_timezone_set('Asia/Colombo');
    }

    public function index()

    {
        $data = array();

        // Load menu data using the custom library
        $menuLoader = new MenuLoader();
        $data = $menuLoader->loadMenuData();

        $boxsizeModel = new BoxSizesModel();
        $data['box_sizes'] = $boxsizeModel->where('custom_size', 0)->findAll();

        $session = session();
        $data['is_cus'] = $session->get('is_customer');

        $employeemodel = new StaffMemberModel();
        $data['riders'] = $employeemodel->where('is_rider', 1)->findAll();

        $supplierModel = new SupplierModel();
        $data['agents'] = $supplierModel
            ->where('sup_cat', 2)
            ->findAll();

        //  $agentLocationModel = new AgentLocationModel();
        //  $data['agent_locations'] = $agentLocationModel
        //     ->select('location')
        //     ->distinct()
        //     ->findAll();

        $OrderReferenceModel = new OrderReferenceModel();
        $a_no = session()->get('acc_no');
        $data['save_references'] = $OrderReferenceModel
            ->select('order_reference.*, pickup_request.*')
            ->join('pickup_request', 'pickup_request.reference = order_reference.reference')
            ->where('order_reference.user_acc', $a_no)
            ->where('order_reference.order_status', '0')
            ->where('pickup_request.common_status', '0')
            ->findAll();

        // var_dump($data['save_references']);die;
        $cob = new COBModel();
        $lastEntry = $cob->orderBy('d_max', 'DESC')->first();
        if ($lastEntry) {
            $data['last_d_max'] = $lastEntry['d_max'];
        } else {
            $data['last_d_max'] = 0;
        }

        return view('pages/master_files/pickup_request', $data);
    }

    public function pickupRequest()
    {
        $boxsizeModel = new BoxSizesModel();
        $data['box_sizes'] = $boxsizeModel->where('custom_size', 0)->findAll();
        return view('client/pickup_request_guest', $data);
    }

    public function pickupRequestHistory()
    {
        $boxsizeModel = new BoxSizesModel();
        $data['box_sizes'] = $boxsizeModel->findAll();
        return view('client/pickup_request_history', $data);
    }

    public function create()
    {
        try {
            // var_dump($this->request->getPost());die;
            $recipient_name = $this->request->getPost('consignee_name');
            $recipient_name2 = $this->request->getPost('other_consignee_names');
            $recipient_contact = $this->request->getPost('consignee_contact');
            $recipient_address = $this->request->getPost('consignee_address');
            $recipient_city = $this->request->getPost('consignee_city');
            $recipient_passport_photo = $this->request->getFile('consignee_passport_image');
            $recipient_paasport_no = $this->request->getPost('consignee_passport_no');
            $recipient_passport_url = $this->request->getPost('consignee_passport_url');

            // var_dump($recipient_name2);die;

            $sender_name = $this->request->getPost('shipper_name');
            $sender_tel = $this->request->getPost('shipper_contact');
            $sender_address = $this->request->getPost('shipper_address');
            $sender_city = $this->request->getPost('shipper_city');
            $sender_mail = $this->request->getPost('shipper_mail');
            $postal_code = $this->request->getPost('postal_code');
            $gift = $this->request->getPost('gift');

            $service_type = $this->request->getPost('service_type');

            if ($service_type == 'Door-to-Door Pickup') {
                $d2d = 1;
            } else {
                $d2d = 0;
            }
            $description = $this->request->getPost('package_description');
            // $packages = $this->request->getPost('packages_data');


            // $order_id = $this->request->getPost('order_id');

            $exchange = $this->request->getPost('exchange');
            $payment_method = $this->request->getPost('payment_method');
            $boxsize = $this->request->getPost('box_size_id');

            $rider_id = $this->request->getPost('assigned_rider');
            $passport_number = $this->request->getPost('passport_no');
            $passport_photo = $this->request->getFile('passport_image');
            $passport_photo_url = $this->request->getPost('passport_photo_url');
            $agent_id = $this->request->getPost('collecting_agent_id');
            $location_id = $this->request->getPost('location_id');


            $is_custom_size = $this->request->getPost('is_custom_size');
            $action = $this->request->getPost('action');
            $reference = $this->request->getPost('reference');
            $id = $this->request->getPost('order_id');

            $cslj = $this->request->getPost('cslj_no');

            // if (!empty($passport_photo)) {
            //     $timestamp = date('YmdHis');
            //     $newFileName = $timestamp . '.' . $passport_photo->getExtension();
            //     $passport_photo->move('assets/images/passports', $newFileName);
            // } else {
            //     $newFileName = $passport_photo_url;
            // }

            // if (!empty($recipient_passport_photo)) {
            //     $timestamp = date('YmdHis');
            //     $newFileName2 = $timestamp . '.' . $recipient_passport_photo->getExtension();
            //     $recipient_passport_photo->move('assets/images/passports', $newFileName2);
            // } else {
            //     $newFileName2 = $recipient_passport_url ?? '';
            // }

            // validate shipper contact and consignee contact
            // Validate shipper contact number (Sri Lankan or Japan)
            // Sri Lankan: 10 digits, starts with 0 (e.g., 0771234567)
            // Japan: 10 or 11 digits, starts with 0 or +81 (e.g., 09012345678 or +819012345678)
            if (
                !preg_match('/^(0\d{9}|(\+81\d{10,11}))$/', $sender_tel)
            ) {
                return $this->respond(['status' => 400, 'message' => 'Invalid Sender Contact Number.', 'success' => false]);
            }

            if (
                !preg_match('/^(0\d{9}|(\+81\d{10,11}))$/', $recipient_contact)
            ) {
                return $this->respond(['status' => 400, 'message' => 'Invalid Recipient Contact Number.', 'success' => false]);
            }

            // Save sender image if valid
            if ($passport_photo && $passport_photo->isValid() && !$passport_photo->hasMoved()) {
                $senderFileName = uniqid('sender_', true) . '.' . $passport_photo->getExtension();
                $passport_photo->move(WRITEPATH . 'assets/images/passports', $senderFileName);
            } else {
                $senderFileName = $passport_photo_url ?? '';
            }

            // Save recipient image if valid
            if ($recipient_passport_photo && $recipient_passport_photo->isValid() && !$recipient_passport_photo->hasMoved()) {
                $recipientFileName = uniqid('recipient_', true) . '.' . $recipient_passport_photo->getExtension();
                $recipient_passport_photo->move(WRITEPATH . 'assets/images/passports', $recipientFileName);
            } else {
                $recipientFileName = $recipient_passport_url ?? '';
            }


            $data = [
                // 'parcel_type' => $parcel_type,
                // 'parcel_des' => $description,
                // 'packages' => $packages,
                // 'order_id' => $order_id,
                'recipient_name' => $recipient_name,
                'recipient_name2' => $recipient_name2,
                'recipient_contact' => $recipient_contact,
                'recipient_address' => $recipient_address,
                'recipient_city' => $recipient_city,
                'recipient_passport_photo' => $recipientFileName,
                'recipient_passport_no' => $recipient_paasport_no,
                // 'enable_exchange' => $exchange,
                'payment_method' => $payment_method,
                'box_id' => $boxsize,
                'datetime' => date('Y-m-d H:i:s'),
                'created_user' => session()->get('username') ?? $this->request->getHeaderLine('X-Username'),
                'sender_mail' => $sender_mail,
                'sender_name' => $sender_name,
                'sender_tel' => $sender_tel,
                'sender_address' => $sender_address,
                'sender_city' => $sender_city,
                'rider_id' => $rider_id,
                'passport_number' => $passport_number,
                'passport_photo' => $senderFileName,
                'agent_id' => $agent_id,
                'agent_location_id' => $location_id,
                'service_type' => $service_type,
                'd2d' => $d2d,
                'postal_code' => $postal_code,
                'gift' => $gift,
            ];

            if ($action == 'save') {

                $saveData = $this->saveOrder($data, $reference, $id);

                if ($saveData == 0) {
                    return $this->respond(['status' => 400, 'message' => 'Failed to Add parcel', 'success' => false]);
                } else {
                    return $this->respond(['action' => 'save', 'status' => 200, 'message' => 'Parcel Added successfully! Order ID: ' . $saveData['id'], 'id' => $saveData['id'], 'reference' => $saveData['reference'], 'success' => true]);
                }
            } else {

                $accountNumbersModel = new AccountNumbersModel();
                $customerModel = new CustomerModel();

                // Check if the customer already exists with the same passport number
                $existingCustomer = $customerModel->where('passport', $passport_number)->where('Name', $sender_name)->first();
                if (!$existingCustomer) {

                    $nextPRCode = $accountNumbersModel->incrementPRCode();
                    $data2 = [
                        'Sup_Acc_No' => '1-2-5-' . $nextPRCode,
                        'Name' => $sender_name,
                        'FullName' => $sender_name,
                        'Address' => $sender_address,
                        'sl_address' => '',
                        'NIC' => '',
                        'TP' => $sender_tel,
                        'Mobile' => $sender_tel,
                        'email' => '',
                        'zipcode' => '',
                        'sl_zipcode' => '',
                        'passport' => $passport_number
                    ];
                    $customerReg = $customerModel->insert($data2);
                    //$customerId = $customerModel->insertID();

                    if ($customerReg) {
                        $accountPostingMode = new AccountPostingModel();
                        $accountPostingMode->insert([
                            'P_Code' => $nextPRCode,
                            'PName' => $sender_name,
                            'B_Code' => 1,
                            'T_Code' => 2,
                            'H_Code' => 5,
                            'L_Code' => '1-2-5-' . $nextPRCode
                        ]);
                    }
                }

                $finalizeData = $this->finalizeOrder($data, $reference, $id, $cslj);
                if ($finalizeData == 0) {
                    return $this->respond(['status' => 400, 'message' => 'Failed to Add parcel', 'success' => false]);
                } else {
                    return $this->respond(['action' => 'finalize', 'status' => 200, 'message' => 'Parcel Added successfully! Order ID: ' . $finalizeData['id'], 'id' => $finalizeData['id'], 'reference' => $finalizeData['reference'], 'success' => false]);
                }
            }
        } catch (\Exception $e) {
            return $this->respond([
                'status' => 'error',
                'message' => 'Error processing request: ' . $e->getMessage(),
                'success' => false
            ]);
        }
    }

    public function saveOrder($data, $reference, $id)
    {
        $PickupRequestModel = new PickupRequestModel();

        if (!empty($id)) {

            log_message('critical', 'update order id: ' . $id);

            if ($PickupRequestModel->where('id', $id)->countAllResults() > 0) {
                // Update existing record
                if ($PickupRequestModel->where('id', $id)->set($data)->update()) {
                    $existingRecord = $PickupRequestModel->where('id', $id)->first();

                    return [
                        'id' => $existingRecord['id'],
                        'reference' => $existingRecord['reference']
                    ];
                }
                return 0;
            }
        } else {

            log_message('critical', 'create new order');
            try {
                // Generate a unique reference ID
                $OrderReferenceModel = new OrderReferenceModel();
                $referenceId = $OrderReferenceModel->insert([
                    'user' => session()->get('username') ?? $this->request->getHeaderLine('X-Username'),
                    'user_acc' => session()->get('acc_no') ?? $this->request->getHeaderLine('X-Acc-No'),
                ]);

                if (!$referenceId) {
                    log_message('error', 'Failed to insert order reference');
                    return 0;
                }

                $insertedRecord = $OrderReferenceModel->find($referenceId);
                if (!$insertedRecord) {
                    log_message('error', 'Failed to retrieve inserted order reference');
                    return 0;
                }

                // Use the generated reference from the inserted record
                $data['reference'] = $insertedRecord['reference'];
                $data['acc_no'] = session()->get('acc_no');
                $data['common_status'] = 0;


                $id = $PickupRequestModel->insert($data, true);

                if ($id > 0) {

                    $this->logOrder(
                        $data['reference'],
                        OrderStatus::PICKUP_REQUEST_OPENED,
                        'Pickup request opened for order: ' . $data['reference']
                    );

                    return [
                        'id' => $id,
                        'reference' => $data['reference']
                    ];
                }

                log_message('error', 'Failed to insert pickup request data');
                return 0;
            } catch (\Exception $e) {
                log_message('error', 'Exception in saveOrder: ' . $e->getMessage());
                return 0;
            }
        }
    }

    public function finalizeOrder($data, $reference, $id, $cslj)
    {

        $PickupRequestModel = new PickupRequestModel();
        if (!empty($id)) {

            $data['common_status'] = 1;
            // $data['reference'] = $reference;
            // Update existing order with the same reference
            if ($PickupRequestModel->where('id', $id)->countAllResults() > 0) {
                // Update existing record
                if ($PickupRequestModel->where('id', $id)->set($data)->update()) {
                    $existingRecord = $PickupRequestModel->where('id', $id)->first();
                    // return $existingRecord['id'];

                    $conformedOrderModel = new ConformedOrderModel();
                    $conformedOrderModel->insert([
                        'reference' => $existingRecord['reference'],
                        'service_type' => $existingRecord['service_type'],
                        'd2d' => $existingRecord['d2d'],
                        // 'parcel_des' => $data['description'],
                        'p_request_id' => $existingRecord['id'],
                        'recipient_name' => $existingRecord['recipient_name'],
                        'recipient_name2' => $existingRecord['recipient_name2'],
                        'recipient_contact' => $existingRecord['recipient_contact'],
                        'recipient_address' => $existingRecord['recipient_address'],
                        'recipient_city' => $existingRecord['recipient_city'],
                        'recipient_passport_no' => $existingRecord['recipient_passport_no'],
                        'recipient_passport_photo' => $existingRecord['recipient_passport_photo'],
                        // 'enable_exchange' => $data['enable_exchange'] ?? 0,
                        'payment_method' => $existingRecord['payment_method'],
                        'datetime' => date('Y-m-d H:i:s'),
                        'created_user' => session()->get('username'),
                        'box_id' => $existingRecord['box_id'],
                        'status' => 0,
                        'sender_name' => $existingRecord['sender_name'],
                        'sender_tel' => $existingRecord['sender_tel'],
                        'sender_address' => $existingRecord['sender_address'],
                        'sender_city' => $existingRecord['sender_city'],
                        'sender_mail' => $existingRecord['sender_mail'],
                        'rider_id' => $existingRecord['rider_id'] ?? null,
                        'passport_number' => $existingRecord['passport_number'] ?? null,
                        'passport_photo' => $existingRecord['passport_photo'] ?? null,
                        'agent_id' => $existingRecord['agent_id'] ?? null,
                        'agent_location_id' => $existingRecord['agent_location_id'] ?? null,
                        'postal_code_jp' => $existingRecord['postal_code_jp'] ?? null,
                        'postal_code' => $existingRecord['postal_code'] ?? null,
                        'acc_no' => session()->get('acc_no'),
                        'gift' => $existingRecord['gift'] ?? null,
                        'cslj_no' => $cslj
                    ]);

                    $this->logOrder(
                        $existingRecord['reference'],
                        OrderStatus::PICKUP_REQUEST_FINALIZED,
                        'Pickup request finalized for order: ' . $existingRecord['reference']
                    );

                    return [
                        'id' => $existingRecord['id'],
                        'reference' => $existingRecord['reference']
                    ];
                }
                return 0;
            }
        } else {
            try {
                // Generate a unique reference ID
                $OrderReferenceModel = new OrderReferenceModel();
                $referenceId = $OrderReferenceModel->insert([
                    'user' => session()->get('username') ?? $this->request->getHeaderLine('X-Username'),
                    'user_acc' => session()->get('acc_no') ?? $this->request->getHeaderLine('X-Acc-No'),
                ]);
                if (!$referenceId) {
                    log_message('critical', 'Failed to insert order reference');
                    return 0;
                }

                $insertedRecord = $OrderReferenceModel->find($referenceId);
                if (!$insertedRecord) {
                    log_message('critical', 'Failed to retrieve inserted order reference');
                    return 0;
                }

                $data['reference'] = $insertedRecord['reference'];
                $data['common_status'] = 1;

                if ($PickupRequestModel->insert($data)) {
                    // return $PickupRequestModel->insertID();
                    $existingRecord = $PickupRequestModel->where('reference', $data['reference'])->first();

                    $conformedOrderModel = new ConformedOrderModel();
                    $conformedOrderModel->insert([
                        'reference' => $existingRecord['reference'],
                        'service_type' => $data['service_type'],
                        // 'parcel_des' => $data['description'],
                        'p_request_id' => $existingRecord['id'],
                        'recipient_name' => $existingRecord['recipient_name'],
                        'recipient_contact' => $existingRecord['recipient_contact'],
                        'recipient_address' => $existingRecord['recipient_address'],
                        'recipient_city' => $existingRecord['recipient_city'],
                        // 'enable_exchange' => $data['enable_exchange'] ?? 0,
                        'payment_method' => $data['payment_method'],
                        'datetime' => date('Y-m-d H:i:s'),
                        'created_user' => session()->get('username') ?? $this->request->getHeaderLine('X-Username'),
                        'box_id' => $existingRecord['box_id'],
                        'status' => 0,
                        'sender_name' => $existingRecord['sender_name'],
                        'sender_tel' => $existingRecord['sender_tel'],
                        'sender_address' => $existingRecord['sender_address'],
                        'sender_city' => $existingRecord['sender_city'],
                        'sender_mail' => $existingRecord['sender_mail'],
                        'rider_id' => $existingRecord['rider_id'] ?? null,
                        'passport_number' => $existingRecord['passport_number'] ?? null,
                        'passport_photo' => $existingRecord['passport_photo'] ?? null,
                        'agent_id' => $existingRecord['agent_id'] ?? null,
                        'agent_location_id' => $existingRecord['agent_location_id'] ?? null,
                        'postal_code_jp' => $existingRecord['postal_code_jp'] ?? null,
                        'postal_code' => $existingRecord['postal_code'] ?? null,
                        'acc_no' => session()->get('acc_no') ?? $this->request->getHeaderLine('X-Acc-No'),
                    ]);
                    return [
                        'id' => $PickupRequestModel->insertID(),
                        'reference' => $data['reference']
                    ];
                }

                log_message('critical', 'Failed to insert pickup request data');

                return 0;
            } catch (\Exception $e) {
                log_message('critical', 'Exception occurred while inserting pickup request data: ' . $e->getMessage());
                return 0;
            }
        }
    }


    //##########ADD CUSTOMER PACKAGE##########
    public function addPackage()
    {
        $cutomerPackagesModel = new CustomerPackgesModel();
        $data[] = array();

        // Get the POST data from the request
        $packageId = $this->request->getPost('package_id');
        $packageType = $this->request->getPost('package_type');
        $packageDescription = $this->request->getPost('package_description');
        $boxSize = $this->request->getPost('box_size');
        $boxSizeText = $this->request->getPost('box_size_text');
        $packagePrice = $this->request->getPost('package_price');
        $packageWeight = $this->request->getPost('package_weight');
        $orderId = $this->request->getPost('order_id');
        $reference = $this->request->getPost('reference');

        $chassie_no = $this->request->getPost('chassie_no');
        $engine_no = $this->request->getPost('engine_no');

        $width = $this->request->getPost('width');
        $height = $this->request->getPost('height');
        $length = $this->request->getPost('length');


        $isCustomSize = $this->request->getPost('is_custom_size');
        $customWidth = $this->request->getPost('custom_width');
        $customHeight = $this->request->getPost('custom_height');
        $customLength = $this->request->getPost('custom_length');
        $customWeight = $this->request->getPost('custom_weight');
        $customPrice = $this->request->getPost('custom_price');
        $extraFee = $this->request->getPost('extra_fee');


        // Custom dimensions (if applicable)
        if ($isCustomSize == '1') {
            $volume = $customWidth * $customHeight * $customLength;
            $box_id = 0; // Custom size does not use a predefined box size 
            $price = $customPrice;
        } else {
            $volume = $width ?? 0 * $height ?? 0 * $length ?? 0;
            $box_id = $boxSize; // Use the predefined box size
            $price = $packagePrice; // Use the predefined package price
        }

        $data = [
            'reference' => $reference,
            'package_type' => $packageType,
            'description' => $packageDescription,
            'weight' => $customWeight ?? $packageWeight,
            'price' => (float)$price,
            'box_id' => $box_id,
            'custom_size' => $isCustomSize,
            'w' => $customWidth ?? $width,
            'h' => $customHeight ?? $height,
            'l' => $customLength ?? $length,
            'volume' => $volume,
            'chassie_no' => $chassie_no ?? '',
            'engine_no' => $engine_no ?? '',
        ];

        // var_dump($data);die;

        $action = $this->request->getPost('action');

        if ($action === 'add_package') {
            try {
                if ($cutomerPackagesModel->insert($data)) {

                    if ($isCustomSize == '1') {
                        $data = [
                            'reference' =>  $reference,
                            'package_id' => $cutomerPackagesModel->insertID(),
                            'description' => 'Extra weight fee',
                            'amount' =>  $extraFee
                        ];
                        $packageExtraFeeModel = new PackageExtraFeeModel();
                        $packageExtraFeeModel->insert($data);
                        if (!$packageExtraFeeModel->insertID()) {
                            return $this->response->setJSON([
                                'status' => 400,
                                'message' => 'Failed to add extra fee',
                                'success' => false
                            ]);
                        }
                    }

                    $getAll = $this->getPackages($reference);
                    return $this->response->setJSON([
                        'status' => 200,
                        'message' => 'Package added successfully',
                        'package_id' => $cutomerPackagesModel->insertID(),
                        'data' => $getAll,
                        'success' => true
                    ]);
                } else {
                    return $this->response->setJSON([
                        'status' => 400,
                        'message' => 'Failed to add package',
                        'success' => false
                    ]);
                }
            } catch (\Exception $e) {
                return $this->response->setJSON([
                    'status' => 500,
                    'message' => 'Error: ' . $e->getMessage(),
                    'success' => false
                ]);
            }
        }
    }

    public function getPackage()
    {
        $ref = $this->request->getPost('reference_id');
        $package = $this->getPackages($ref);

        if ($package) {
            return $this->response->setJSON([
                'status' => 200,
                'data' => $package
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'Package not found'
            ]);
        }
    }
    //##########GET CUSTOMER PACKAGES##########
    public function getPackages($reference)
    {
        $cutomerPackagesModel = new CustomerPackgesModel();
        $boxsizeModel = new BoxSizesModel();
        $packages = $cutomerPackagesModel->where('reference', $reference)->findAll();

        // If packages exist, get box dimensions for non-custom sizes
        if (!empty($packages)) {
            foreach ($packages as &$package) {
                if ($package['custom_size'] == 0 && !empty($package['box_id']) && $package['box_id'] != 0) {
                    // Get box dimensions from box_sizes table
                    $boxSize = $boxsizeModel->find($package['box_id']);
                    if ($boxSize) {
                        $package['w'] = $boxSize['width'];
                        $package['h'] = $boxSize['height'];
                        $package['l'] = $boxSize['length'];
                        $package['volume'] = $boxSize['volume'];
                    }
                }
            }
        }

        if (empty($packages)) {
            return null;
        } else {
            return  $packages;
        }
    }
    public function getPaymentAmount()
    {
        $reference = $this->request->getPost('reference');
        $CustomerPackgesModel = new CustomerPackgesModel();
        $paymentDetails = $CustomerPackgesModel->selectSum('price')->where('reference', $reference)->first();
        $paymentDetails['price'] = $paymentDetails['price'] ?? 0;

        // reference have extra fee
        $packageExtraFeeModel = new PackageExtraFeeModel();
        $extraFee = $packageExtraFeeModel->selectSum('amount')->where('reference', $reference)->first();
        $paymentDetails['extra_fee'] = $extraFee['amount'] ?? 0;

        if ($paymentDetails) {
            return $this->response->setJSON([
                'status' => 200,
                'data' => $paymentDetails,
                'success' => true
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'Payment details not found',
                'success' => false
            ]);
        }
    }

    //##########DELETE CUSTOMER PACKAGE##########
    public function deletePackage()
    {
        $cutomerPackagesModel = new CustomerPackgesModel();
        $packageId = $this->request->getPost('package_id');
        $reference = $this->request->getPost('reference');

        // delete package related extra fees
        $this->deleteExtraFee($packageId, $reference);

        if ($cutomerPackagesModel->where('id', $packageId)->delete()) {
            $getAll = $this->getPackages($reference);
            return $this->response->setJSON([
                'status' => 200,
                'message' => 'Package deleted successfully',
                // 'data' => $getAll,
                'success' => true
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Failed to delete package',
                'success' => false
            ]);
        }
    }



    public function createGuest()
    {
        try {
            $waybill = $this->request->getPost('waybill_id');
            $parcel_type = $this->request->getPost('parcel_type');
            $description = $this->request->getPost('description');
            $order_id = $this->request->getPost('order_id');
            $recipient_name = $this->request->getPost('recipient_name');
            $recipient_contact = $this->request->getPost('recipient_contact');
            $recipient_address = $this->request->getPost('recipient_address');
            $recipient_city = $this->request->getPost('recipient_city');
            $exchange = $this->request->getPost('exchange');
            $payment_method = $this->request->getPost('payment_method');
            $boxsize = $this->request->getPost('box_sizes');
            $sender_name = $this->request->getPost('sender_name');
            $sender_tel = $this->request->getPost('sender_contact');
            $sender_address = $this->request->getPost('sender_address');
            $sender_city = $this->request->getPost('sender_city');
            $sender_mail = $this->request->getPost('sender_email');
            $passport_number = $this->request->getPost('passport_number');
            $passport_photo = $this->request->getFile('passport_photo');

            $validation = service('validation');
            $validation->setRules([
                'parcel_type' => 'required|max_length[10]',
                'description' => 'max_length[400]',
                'order_id' => 'max_length[50]',
                'recipient_name' => 'required|max_length[200]',
                'recipient_contact' => 'required|max_length[20]',
                'recipient_address' => 'required|max_length[400]',
                'recipient_city' => 'required|max_length[200]',
                'exchange' => 'max_length[1]',
                'payment_method' => 'required|max_length[15]',
                'box_sizes' => 'required|max_length[6]',
                'sender_name' => 'required|max_length[200]',
                'sender_contact' => 'required|max_length[20]',
                'sender_address' => 'required|max_length[400]',
                'sender_city' => 'required|max_length[200]',
                'sender_email' => 'valid_email|max_length[200]|required',
                'passport_number' => 'strip_tags',
            ]);

            if (!$validation->withRequest($this->request)->run()) {
                return $this->response->setStatusCode(400)->setJSON($validation->getErrors());
            }

            if ($boxsize == 'custom') {
                try {

                    $boxSizesModel = new BoxSizesModel();

                    $w = $this->request->getPost('custom_width');
                    $h = $this->request->getPost('custom_height');
                    $l = $this->request->getPost('custom_length');
                    $v = $w * $h * $l;
                    // Get POST data
                    $data = [
                        'description' => 'Custom Box Size',
                        'height' => $h,
                        'width' => $w,
                        'length' => $l,
                        'volume' => $v,
                        'weight' => '',
                        'price' => $this->request->getPost('amount'),
                        'custom_size' => 1,
                    ];

                    // Insert the data
                    if (!$boxSizesModel->insert($data)) {
                        throw new \Exception('Failed to add box size', 500);
                    }
                    $boxsize = $boxSizesModel->insertID();
                } catch (\Exception $e) {
                    return $this->response->setJSON([
                        'success' => false,
                        'message' => $e->getMessage(),
                        'code' => $e->getCode()
                    ])->setStatusCode($e->getCode() ?: 500);
                }
            }

            if (!empty($passport_photo)) {
                $timestamp = date('YmdHis');
                $newFileName = $timestamp . '.' . $passport_photo->getExtension();
                $passport_photo->move('assets/images/passports', $newFileName);
            } else {
                $newFileName = "";
            }

            $data = [
                'waybill_id' => $waybill,
                'parcel_type' => $parcel_type,
                'parcel_des' => $description,
                'order_id' => $order_id,
                'recipient_name' => $recipient_name,
                'recipient_contact' => $recipient_contact,
                'recipient_address' => $recipient_address,
                'recipient_city' => $recipient_city,
                'enable_exchange' => $exchange,
                'payment_method' => $payment_method,
                'box_id' => $boxsize,
                'datetime' => date('Y-m-d H:i:s'),
                'created_user' => session()->get('username'),
                'sender_name' => $sender_name,
                'sender_tel' => $sender_tel,
                'sender_address' => $sender_address,
                'sender_city' => $sender_city,
                'sender_mail' => $sender_mail,
                'passport_number' => $passport_number,
                'passport_photo' => $newFileName,
            ];

            $PickupRequestModel = new PickupRequestModel();
            $dataAdded = $PickupRequestModel->insert($data);
            $insertId = $PickupRequestModel->insertID();

            if ($dataAdded) {
                return $this->response->setJSON(['status' => 200, 'message' => 'Parcel Added successfully! Order ID: ' . $insertId, 'id' => $insertId]);
            } else {
                return $this->response->setJSON(['status' => 400, 'message' => 'Failed to Add parcel']);
            }
        } catch (\Exception $e) {
            return $this->response->setJSON([
                'status' => 'error',
                'message' => 'Error processing request: ' . $e->getMessage()
            ]);
        }
    }

    public function accept()
    {
        $reference = $this->request->getPost('reference');
        $d_id = $this->request->getPost('d_id');
        $cslj_no = $this->request->getPost('cslj_no');
        $serviceType = $this->request->getPost('s_type');


        if (empty($reference)) {
            return $this->response->setJSON(['status' => '400', 'message' => 'Reference is required.']);
        }
        $conformedOrderModel = new ConformedOrderModel();
        $idIsExists = $conformedOrderModel->where('reference', $reference)->first();

        $isCslExists = $conformedOrderModel->where('cslj_no', $cslj_no)->first();

        if ($isCslExists) {
            return $this->response->setJSON(['status' => '400', 'message' => 'CSLJ No already Existed.']);
        }

        if ($serviceType == 'Office Visit' || $serviceType != null) {
            if ($idIsExists) {
                $conformedOrderModel->where('reference', $reference)->set(['status' => '4', 'cslj_no' => $cslj_no, 'conformed_date' => date('Y-m-d H:i:s'), 'wh_handover_date' => date('Y-m-d H:i:s')])->update();
                $this->logOrder(
                    $reference,
                    OrderStatus::ORDER_CONFIRMED,
                    'Order with ref: ' . $reference . ' confirmed successfully.',
                );
                return $this->response->setJSON(['status' => '200', 'message' => 'Order accepted successfully.']);
            } else {
                return $this->response->setJSON(['status' => '404', 'message' => 'Order not found.']);
            }
        } else {
            $ifNotExistsRider = $conformedOrderModel
                ->where('reference', $reference)
                ->where('rider_id', null) // checks for IS NULL
                ->first();
            if ($ifNotExistsRider && empty($d_id)) {
                return $this->response->setJSON(['status' => '400', 'message' => 'Please assign a rider.']);
            }
            if ($idIsExists) {
                if (!empty($d_id)) {
                    $conformedOrderModel->where('reference', $reference)->set(['status' => '1', 'cslj_no' => $cslj_no, 'rider_id' => $d_id, 'conformed_date' => date('Y-m-d H:i:s')])->update();
                } else {
                    $conformedOrderModel->where('reference', $reference)->set(['status' => '1', 'cslj_no' => $cslj_no, 'conformed_date' => date('Y-m-d H:i:s')])->update();
                }

                $this->logOrder(
                    $reference,
                    OrderStatus::ORDER_CONFIRMED,
                    'Order with ref: ' . $reference . ' confirmed successfully.',
                );

                return $this->response->setJSON(['status' => '200', 'message' => 'Order accepted successfully.']);
            } else {
                return $this->response->setJSON(['status' => '404', 'message' => 'Order not found.']);
            }
        }
    }

    public function reject()
    {
        $reference = $this->request->getPost('id');

        $conformedOrderModel = new ConformedOrderModel();
        $idIsExists = $conformedOrderModel->where('reference', $reference)->first();

        if ($idIsExists) {
            $conformedOrderModel->where('reference', $reference)->set(['status' => '2'])->update();

            $this->logOrder(
                $reference,
                OrderStatus::ORDER_REJECTED,
                'Order rejected with: ' . $reference,
                1
            );

            return $this->response->setJSON(['status' => 'success', 'message' => 'Order deleted successfully.']);
        } else {
            return $this->response->setJSON(['status' => 'error', 'message' => 'Order not found.']);
        }
    }

    public function getCusDet()
    {
        $acc_no = session()->get('acc_no');
        $is_customer = session()->get('is_customer');
        if ($is_customer == 1) {
            $customerModel = new CustomerModel();
            $cusDetails = $customerModel->where('Sup_Acc_No', $acc_no)->get()->getRow();
            if ($cusDetails === null) {
                return $this->response->setJSON([
                    'status' => 404,
                    'message' => 'Customer not found'
                ]);
            }
            //log('Customer Details: ' . json_encode($cusDetails));
            return $this->response->setJSON([
                'status' => 200,
                'data' => $cusDetails
            ]);
        } else {
            return $this->response->setJSON(
                [
                    'status' => 400,
                    'message' => 'Not a customer.'
                ]
            );
        }
    }

    public function getContacts()
    {
        $contactNo = $this->request->getGet('term');
        $PickupRequestModel = new PickupRequestModel();
        $contactDetails = $PickupRequestModel->like('sender_tel', $contactNo)->groupBy(['sender_tel', 'passport_number'])->findAll();

        if (empty($contactDetails)) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'No contacts found'
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 200,
                'data' => $contactDetails
            ]);
        }
    }

    public function getPassportNumbers()
    {
        $passportNo = $this->request->getGet('term');
        $PickupRequestModel = new PickupRequestModel();
        $passportDetails = $PickupRequestModel->like('passport_number', $passportNo)->groupBy('passport_number')->findAll();

        if (empty($passportDetails)) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'No passport numbers found'
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 200,
                'data' => $passportDetails
            ]);
        }
    }

    public function printPickupRequest()
    {
        $data = array();

        $id = $this->request->getGet('id');
        $data['id'] = $id;



        return view('pages/report/pickup_request_print', $data);
    }

    public function printConformedOrder()
    {
        $data = array();

        $id = $this->request->getGet('id');
        $data['id'] = $id;

        return view('pages/report/conformed_order_print', $data);
    }

    public function printDriverPickupRequest()
    {
        $data = array();

        $id = $this->request->getGet('id');
        $data['id'] = $id;

        return view('pages/report/driver_conformed_order_print', $data);
    }

    public function calculatePrice()
    {
        // Get input
        $width  = $this->request->getPost('width');
        $height = $this->request->getPost('height');
        $length = $this->request->getPost('length');

        // Validate input
        if (!is_numeric($width) || !is_numeric($height) || !is_numeric($length)) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Invalid dimensions',
                'success' => false
            ]);
        }

        // Calculate volume
        $volume = $width * $height * $length;

        $calBoxPrice = new CalBoxPrice();

        $price = $calBoxPrice->calculatePriceVolume($volume);
        // Return result
        return $this->response->setJSON([
            'status' => 200,
            'volume' => round($volume, 3),
            'price' => round($price, 2),
            'success' => true
        ]);
    }

    public function calculateWeightPrice()
    {
        // Get input
        $weight = $this->request->getPost('weight');

        // Validate using CodeIgniter's validation service
        $validation = service('validation');
        $validation->setRules([
            'weight' => 'required|numeric|greater_than[0]|less_than_equal_to[1000]'
        ]);

        if (!$validation->withRequest($this->request)->run()) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Validation failed',
                'errors' => $validation->getErrors()
            ]);
        }

        // Convert to float
        $weight = (float) $weight;

        $calBoxPrice = new CalBoxPrice();
        $result = $calBoxPrice->calculatePriceWeight($weight);

        // Return result
        return $this->response->setJSON([
            'status' => 200,
            'price' => round($result['price'], 2),
            'message' => $result['message']
        ]);
    }

    public function searchCustomer()
    {
        $customerModel = new CustomerModel();
        // $conformedOrderModel = new ConformedOrderModel();

        $searchTerm = $this->request->getGet('term');

        if (empty($searchTerm)) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Search term is required'
            ]);
        }

        $customers = $customerModel
            ->select('FullName, Sup_Acc_No, Address, TP, passport, passport_photo, city,email')
            ->groupStart()
            ->like('FullName', $searchTerm)
            ->orLike('Name', $searchTerm)
            ->orLike('TP', $searchTerm)
            ->orLike('passport', $searchTerm)
            ->groupEnd()
            ->findAll();

        // $customers = $conformedOrderModel
        //     ->select('sender_name as FullName, sender_tel as Tel, sender_address as Address, sender_city as City, postal_code_jp as PostalCode')
        //     ->groupStart()
        //     ->like('sender_name', $searchTerm)
        //     ->orLike('sender_tel', $searchTerm)
        //     ->orLike('sender_address', $searchTerm)
        //     ->orLike('sender_city', $searchTerm)
        //     ->groupEnd()
        //     ->findAll();

        if (empty($customers)) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'No customers found'
            ]);
        }

        return $this->response->setJSON([
            'status' => 200,
            'data' => $customers
        ]);
    }

    public function getUserPassportInBase64()
    {
        $accNo = $this->request->getHeaderLine('X-Acc-No');

        if (empty($accNo)) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Account number is required',
                'success' =>  false
            ]);
        }

        $customerModel = new CustomerModel();
        $customer = $customerModel->where('Sup_Acc_No', $accNo)->first();

        if (!$customer || empty($customer['passport_photo'])) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'Customer or passport photo not found',
                'success' =>  false
            ]);
        }

        $filePath = WRITEPATH . 'assets/images/passports/' . $customer['passport_photo'];

        if (!file_exists($filePath)) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'Passport photo file not found',
                'success' =>  false
            ]);
        }

        $fileData = file_get_contents($filePath);
        $base64 = base64_encode($fileData);
        $mimeType = mime_content_type($filePath);
        $base64Image = 'data:' . $mimeType . ';base64,' . $base64;

        return $this->response->setJSON([
            'status' => 200,
            'data' => [
                'passport_number' => $customer['passport'],
                'passport_photo_base64' => $base64Image
            ],
            'success' =>  true
        ]);
    }

    public function searchConsignee()
    {
        $conformedOrderModel = new ConformedOrderModel();
        $searchTerm = $this->request->getGet('term');

        // Get acc_no from session
        $acc_no = session()->get('acc_no');

        if (empty($searchTerm)) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Search term is required'
            ]);
        }
        $consignees = $conformedOrderModel
            ->select('recipient_name, recipient_contact, recipient_address, recipient_city,postal_code,recipient_passport_no, recipient_passport_photo')
            ->where('acc_no', $acc_no) // Filter by acc_no
            ->groupStart()
            ->like('recipient_name', $searchTerm)
            ->orLike('recipient_contact', $searchTerm)
            ->orLike('recipient_address', $searchTerm)
            ->orLike('recipient_city', $searchTerm)
            ->groupEnd()
            ->findAll();
        if (empty($consignees)) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'No consignees found'
            ]);
        }
        return $this->response->setJSON([
            'status' => 200,
            'data' => $consignees
        ]);
    }



    public function addExtraFee()
    {
        $packageExtraFeeModel = new PackageExtraFeeModel();
        // Validate input data
        $validation = service('validation');
        $validation->setRules([
            'reference' => 'required|max_length[50]',
            'package_id' => 'required|integer|greater_than[0]',
            'description' => 'required|max_length[255]',
            'amount' => 'required|decimal|greater_than[0]'
        ]);

        if (!$validation->withRequest($this->request)->run()) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Validation failed',
                'errors' => $validation->getErrors()
            ]);
        }

        $data = [
            'reference' => $this->request->getPost('reference'),
            'package_id' => $this->request->getPost('package_id'),
            'description' => $this->request->getPost('description'),
            'amount' => $this->request->getPost('amount')
        ];

        try {
            if ($packageExtraFeeModel->insert($data)) {
                $insertedId = $packageExtraFeeModel->insertID();
                return $this->response->setJSON([
                    'status' => 200,
                    'message' => 'Extra fee added successfully',
                    'id' => $insertedId
                ]);
            } else {
                return $this->response->setJSON([
                    'status' => 400,
                    'message' => 'Failed to add extra fee'
                ]);
            }
        } catch (\Exception $e) {
            return $this->response->setJSON([
                'status' => 500,
                'message' => 'Error: ' . $e->getMessage()
            ]);
        }
    }

    public function updateExtraFee()
    {
        $packageExtraFeeModel = new PackageExtraFeeModel();
        // Validate input data
        $validation = service('validation');
        $validation->setRules([
            'id' => 'required|integer|greater_than[0]',
            'description' => 'permit_empty|max_length[255]',
            'package_id' => 'required|integer|greater_than[0]',
            'weight' => 'required|decimal|greater_than[0]',
            'amount' => 'required|decimal|greater_than[0]'
        ]);

        if (!$validation->withRequest($this->request)->run()) {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Validation failed',
                'errors' => $validation->getErrors()
            ]);
        }

        $data = [
            'description' => $this->request->getPost('description'),
            'amount' => $this->request->getPost('amount')
        ];

        $id = $this->request->getPost('id');

        try {
            if ($packageExtraFeeModel->update($id, $data)) {
                $CustomerPackgesModel = new CustomerPackgesModel();

                $packageId = $this->request->getPost('package_id');
                $weight = $this->request->getPost('weight');
                $package = $CustomerPackgesModel->find($packageId);
                if ($package) {
                    $CustomerPackgesModel->update($packageId, ['weight' => $weight]);
                }

                return $this->response->setJSON([
                    'status' => 200,
                    'message' => 'Extra fee updated successfully'
                ]);
            } else {
                return $this->response->setJSON([
                    'status' => 400,
                    'message' => 'Failed to update extra fee'
                ]);
            }
        } catch (\Exception $e) {
            return $this->response->setJSON([
                'status' => 500,
                'message' => 'Error: ' . $e->getMessage()
            ]);
        }
    }

    public function getExtraFees()
    {
        $reference = $this->request->getGet('reference');
        $packageExtraFeeModel = new PackageExtraFeeModel();
        $extraFees = $packageExtraFeeModel->where('reference', $reference)->findAll();

        if (empty($extraFees)) {
            return $this->response->setJSON([
                'status' => 404,
                'message' => 'No extra fees found for this reference'
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 200,
                'data' => $extraFees
            ]);
        }
    }
    public function deleteExtraFee($packageId, $reference)
    {
        $packageExtraFeeModel = new PackageExtraFeeModel();

        // Delete all extra fees related to the package
        if ($packageExtraFeeModel->where('package_id', $packageId)->where('reference', $reference)->delete()) {
            return 200;
        } else {
            return 400;
        }
    }
    public function deleteOrder()
    {
        $reference = $this->request->getPost('reference');
        $orderDetails = new OrderDetails();

        $delete = $orderDetails->deleteOrder($reference);
        if ($delete) {
            return $this->response->setJSON([
                'status' => 200,
                'message' => 'Order deleted successfully'
            ]);
        } else {
            return $this->response->setJSON([
                'status' => 400,
                'message' => 'Failed to delete order'
            ]);
        }
    }

    public function getLastInsertedCslj()
    {
        $conformedOrderModel = new ConformedOrderModel();
        // Get last inserted csl number
        $lastCsl = $conformedOrderModel
            ->select('cslj_no')
            ->where('cslj_no IS NOT NULL', null, false)
            ->where('cslj_no !=', '')
            ->orderBy('id', 'DESC')
            ->first();

        log_message('critical', json_encode($lastCsl));
        $cslj_no = $lastCsl ? $lastCsl['cslj_no'] : null;

        return $this->response->setJSON(['cslj_no' => $cslj_no]);
    }

    public function change_password()
    {
        // get user_id from session
        $user_id = !empty(session()->get('user_id')) ? session()->get('user_id') : $this->request->getHeaderLine('user_id');

        // validate current_password, new_password and confirm_password
        $validation = \Config\Services::validation();
        $validation->setRules([
            'current_password' => 'required|strip_tags',
            'new_password' => 'required|strip_tags',
            'confirm_password' => 'required|strip_tags',
        ]);

        // validate request
        if ($validation->withRequest($this->request)->run()) {
            // get current_password, new_password and confirm_password
            $current_password = $this->request->getVar('current_password');
            $new_password = $this->request->getVar('new_password');
            $confirm_password = $this->request->getVar('confirm_password');

            // get user data from userModel
            $user_model = new UserModel();
            $user = $user_model->where('id', $user_id)->first();

            // check if current_password is correct
            if (password_verify($current_password, $user['pass'])) {
                // check if new_password and confirm_password are same
                if ($new_password == $confirm_password) {
                    // update password
                    $user_model->update($user_id, ['pass' => password_hash($new_password, PASSWORD_DEFAULT)]);
                    // return success message
                    return json_encode(array('status' => 201, 'message' => 'Password changed successfully!'));
                } else {
                    // return error message
                    return json_encode(array('status' => 400, 'message' => 'New password and confirm password are not same!'));
                }
            } else {
                // return error message
                return json_encode(array('status' => 400, 'message' => 'Current password is incorrect!'));
            }
        } else {
            // return error message
            return json_encode(array('status' => 400, 'message' => 'Please fill all the required fields!'));
        }
    }

    public function updateCustomerProfile()
    {
        $customerModel = new CustomerModel();
        $cusId = session()->get('customer_id');

        if (empty($cusId)) {
            $cusId = $this->request->getHeaderLine('customer_id');
        }

        $fromApi = $this->request->getPost('from_api');

        //Get the customer profile picture from the request
        $profilePicture = $this->request->getFile('customer_prof_pic');
        $newFileName = '';

        if ($profilePicture && $profilePicture->isValid() && !$profilePicture->hasMoved()) {
            $timestamp = date('YmdHis');
            $newFileName = $timestamp . '.' . $profilePicture->getExtension();

            $profilePicture->move('assets/images/users', $newFileName);
            if (!$fromApi) {
                // Update the session with the new profile picture name
                session()->set('customer_prof_pic', $newFileName);
            }
        }

        $passport_photo = $this->request->getFile('customer_passport_book');

        if ($passport_photo && $passport_photo->isValid() && !$passport_photo->hasMoved()) {
            $cusPassportPhoto = uniqid('cus_', true) . '.' . $passport_photo->getExtension();
            $passport_photo->move('assets/images/passports', $cusPassportPhoto);
        }

        $data = [
            // 'Name' => $this->request->getPost('customer_name'),
            'FullName' => $this->request->getPost('customer_f_name'),
            'Address' => $this->request->getPost('customer_address'),
            'passport' => $this->request->getPost('customer_pass_no'),
            'TP' => $this->request->getPost('customer_phone'),
            'city' => $this->request->getPost('customer_city'),
            'zipcode' => $this->request->getPost('customer_zip_jp'),
            'email' => $this->request->getPost('customer_email'),
            'NIC' => $this->request->getPost('customer_nic'),
            'sl_address' => $this->request->getPost('customer_address_sl'),
            'sl_zipcode' => $this->request->getPost('customer_zip_sl'),
            'Mobile' => $this->request->getPost('customer_phone_sl'),
            // 'prof_pic' => $newFileName ?? session()->get('customer_prof_pic'),
            'passport_photo' => $cusPassportPhoto ?? '',
        ];

        if (!empty($newFileName) || !empty(session()->get('customer_prof_pic'))) {
            $data['prof_pic'] = $newFileName ?? session()->get('customer_prof_pic');
        }

        $updateCus = $customerModel->update($cusId, $data);

        if (!$fromApi) {
            // Update session data
            // session()->set('customer_name', $data['Name']);
            session()->set('customer_f_name', $data['FullName']);
            session()->set('customer_address', $data['Address']);
            session()->set('customer_pass_no', $data['passport']);
            session()->set('customer_phone', $data['TP']);
            session()->set('customer_city', $data['city']);
            session()->set('customer_zip_jp', $data['zipcode']);
            session()->set('customer_email', $data['email']);
            session()->set('customer_nic', $data['NIC']);
            session()->set('customer_address_sl', $data['sl_address']);
            session()->set('customer_zip_sl', $data['sl_zipcode']);
            session()->set('customer_phone_sl', $data['Mobile']);
            session()->set('customer_passport_photo', $data['passport_photo'] ?? null);
        }

        if ($updateCus) {
            return json_encode(array('status' => 200, 'message' => 'Successfully updated!'));
        } else {
            return json_encode(array('status' => 500, 'message' => 'Failed to update profile.'));
        }
    }
}
