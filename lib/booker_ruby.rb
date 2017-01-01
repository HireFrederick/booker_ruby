require 'booker/version'

# External Libs
require 'oj'
require 'httparty'
require 'active_support/json'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric/time.rb'
require 'active_support/time_with_zone'
require 'active_support/time'
require 'jwt'

# Core
require 'booker/booker'

# Errors
require 'booker/errors'

# Models
require 'booker/model'

# V4 Models
require 'booker/v4/models/model'

# Types
require 'booker/v4/models/type'
require 'booker/v4/models/country'
require 'booker/v4/models/status'
require 'booker/v4/models/source'
require 'booker/v4/models/business_type'
require 'booker/v4/models/category'
require 'booker/v4/models/sub_category'
require 'booker/v4/models/customer_record_type'
require 'booker/v4/models/gender'
require 'booker/v4/models/preferred_staff_gender'
require 'booker/v4/models/payment_method'

# Addresses
require 'booker/v4/models/address'
require 'booker/v4/models/shipping_address'

# Prices
require 'booker/v4/models/price'
require 'booker/v4/models/final_total'
require 'booker/v4/models/original_price'
require 'booker/v4/models/discount'
require 'booker/v4/models/receipt_display_price'
require 'booker/v4/models/tag_price'
require 'booker/v4/models/current_price'

# Customers
require 'booker/v4/models/customer'
require 'booker/v4/models/customer_2'

# Locations
require 'booker/v4/models/location'
require 'booker/v4/models/spa'

# Employees
require 'booker/v4/models/employee'
require 'booker/v4/models/teacher'
require 'booker/v4/models/teacher_2'

# Other Models
require 'booker/v4/models/time_zone'
require 'booker/v4/models/appointment'
require 'booker/v4/models/appointment_treatment'
require 'booker/v4/models/dynamic_price'
require 'booker/v4/models/room'
require 'booker/v4/models/treatment'
require 'booker/v4/models/spa_employee_availability_search_item'
require 'booker/v4/models/available_time'
require 'booker/v4/models/class_instance'
require 'booker/v4/models/online_booking_settings'
require 'booker/v4/models/user'
require 'booker/v4/models/location_day_schedule'
require 'booker/v4/models/itinerary_time_slots_list'
require 'booker/v4/models/itinerary_time_slot'
require 'booker/v4/models/treatment_time_slot'
require 'booker/v4/models/multi_service_availability_result'
require 'booker/v4/models/notification_settings'
require 'booker/v4/models/feature_settings'

# V5 Models
require 'booker/v5/models/model'
require 'booker/v5/models/location_hour'
require 'booker/v5/models/availability'
require 'booker/v5/models/service'
require 'booker/v5/models/service_category'
require 'booker/v5/models/availability_result'


# Base Client
require 'booker/client'

# V4 Rest
require 'booker/v4/request_helper'
require 'booker/v4/common_rest'
require 'booker/v4/business_rest'
require 'booker/v4/customer_rest'

# Token Store
require 'booker/generic_token_store'

# Client Subclasses
require 'booker/v4/business_client'
require 'booker/v4/customer_client'
require 'booker/v4.1/availability'
require 'booker/v4.1/booking'
require 'booker/v4.1/merchant'
require 'booker/v5/availability'

# Helpers
require 'booker/helpers/logging_helper'
require 'booker/helpers/active_support_helper'
