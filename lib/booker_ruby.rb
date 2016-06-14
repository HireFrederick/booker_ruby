require 'booker/version'

# External Libs
require 'oj'
require 'httparty'
require 'active_support/json'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric/time.rb'
require 'active_support/time_with_zone'
require 'active_support/time'

# Core
require 'booker/booker'

# Errors
require 'booker/errors'

# Models
require 'booker/models/model'

# Types
require 'booker/models/type'
require 'booker/models/country'
require 'booker/models/status'
require 'booker/models/source'
require 'booker/models/business_type'
require 'booker/models/category'
require 'booker/models/sub_category'
require 'booker/models/customer_record_type'
require 'booker/models/gender'
require 'booker/models/preferred_staff_gender'
require 'booker/models/payment_method'

# Addresses
require 'booker/models/address'
require 'booker/models/shipping_address'

# Prices
require 'booker/models/price'
require 'booker/models/final_total'
require 'booker/models/original_price'
require 'booker/models/discount'
require 'booker/models/receipt_display_price'
require 'booker/models/tag_price'
require 'booker/models/current_price'

# Customers
require 'booker/models/customer'
require 'booker/models/customer_2'

# Locations
require 'booker/models/location'
require 'booker/models/spa'

# Employees
require 'booker/models/employee'
require 'booker/models/teacher'
require 'booker/models/teacher_2'

# Other Models
require 'booker/models/time_zone'
require 'booker/models/appointment'
require 'booker/models/appointment_treatment'
require 'booker/models/dynamic_price'
require 'booker/models/room'
require 'booker/models/treatment'
require 'booker/models/spa_employee_availability_search_item'
require 'booker/models/available_time'
require 'booker/models/class_instance'
require 'booker/models/online_booking_settings'
require 'booker/models/user'
require 'booker/models/location_day_schedule'
require 'booker/models/itinerary_time_slots_list'
require 'booker/models/itinerary_time_slot'
require 'booker/models/treatment_time_slot'
require 'booker/models/multi_service_availability_result'
require 'booker/models/notification_settings'
require 'booker/models/feature_settings'

# Base Client
require 'booker/client'

# Rest
require 'booker/common_rest'
require 'booker/business_rest'
require 'booker/customer_rest'

# Token Store
require 'booker/generic_token_store'

# Client Subclasses
require 'booker/business_client'
require 'booker/customer_client'

# Helpers
require 'booker/helpers/logging_helper'
require 'booker/helpers/active_support_helper'
