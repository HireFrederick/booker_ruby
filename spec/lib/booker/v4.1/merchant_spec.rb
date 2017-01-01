require 'spec_helper'

describe Booker::V41::Merchant do
  let(:client) do
    Booker::V41::Merchant.new(
      client_id: 'foo_client_id',
      client_secret: 'foo_client_secret',
    )
  end
  let(:booker_location_id) { 10257 }
  let(:response) { 'resp' }

  before { allow(client).to receive(:access_token).and_return 'access_token' }

  it { is_expected.to be_a Booker::Client }

  describe '#appointments' do
    let(:from_start_date) { Time.zone.at(1375039103) }
    let(:to_start_date) { Time.zone.at(1469743856) }
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      LocationID: booker_location_id,
      FromStartDate: '/Date(1374984000000)/',
      ToStartDate: '/Date(1469678400000)/'
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/merchant/appointments',
        params: expected_params,
        model: Booker::V4::Models::Appointment,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.appointments(location_id: booker_location_id, start_date: from_start_date, end_date: to_start_date)).to eq []
    end

    context 'other options' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        LocationID: booker_location_id,
        FromStartDate: '/Date(1374984000000)/',
        ToStartDate: '/Date(1469678400000)/',
        another_option: 'foo'
      })}

      it 'adds other options passed in to the params' do
        expect(client.appointments(location_id: booker_location_id, start_date: from_start_date, end_date: to_start_date, options: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#customers' do
    let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
      access_token: 'access_token',
      FilterByExactLocationID: true,
      CustomerRecordType: 1,
      LocationID: booker_location_id
    })}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:paginated_request).with(
        method: :post,
        path: '/v4.1/merchant/customers',
        params: expected_params,
        model: Booker::V4::Models::Customer,
        fetch_all: true
      ).and_return([])
    end

    it 'delegates to get_booker_resources' do
      expect(client.customers(location_id: booker_location_id)).to eq []
    end

    context 'other options' do
      let(:expected_params) {described_class::DEFAULT_PAGINATION_PARAMS.merge({
        access_token: 'access_token',
        FilterByExactLocationID: true,
        CustomerRecordType: 1,
        LocationID: booker_location_id,
        another_option: 'foo'
      })}

      it 'adds other options passed in to the params' do
        expect(client.customers(location_id: booker_location_id, options: {another_option: 'foo'})).to eq []
      end
    end
  end

  describe '#create_special' do
    let(:start_date) { Time.zone.at(1438660800) }
    let(:end_date) { Time.zone.at(1438747199) }
    let(:coupon_code) { 'fred123456' }
    let(:name) { 'Frederick 20% Off' }
    let(:options) {{
      Type: 2,
      AdjustmentType: 1,
      DiscountType: 1,
      DiscountAmount: 20,
      MaxRedemptions: 1,
      Description: 'foo',
      BookingStartDate: start_date,
      BookingEndDate: end_date,
      IsExclusiveWithAll: true
    }}
    let(:result) do
      client.create_special(
        location_id: booker_location_id,
        start_date: start_date,
        end_date: end_date,
        coupon_code: coupon_code,
        name: name,
        options: options
      )
    end
    let(:expected_params) {{
      access_token: 'access_token',
      LocationID: booker_location_id,
      ApplicableStartDate: '/Date(1438675200000)/',
      ApplicableEndDate: '/Date(1438761599000)/',
      CouponCode: 'fred123456',
      Name: 'Frederick 20% Off',
      Type: 2,
      AdjustmentType: 1,
      DiscountType: 1,
      DiscountAmount: 20,
      MaxRedemptions: 1,
      Description: 'foo',
      BookingStartDate: Booker::V4::Models::Model.time_to_booker_datetime(start_date),
      BookingEndDate: Booker::V4::Models::Model.time_to_booker_datetime(end_date),
      IsExclusiveWithAll: true
    }}

    before do
      expect(client).to receive(:access_token).and_return 'access_token'
      expect(client).to receive(:post).with('/v4.1/merchant/special', expected_params).and_return 'response'
    end

    it 'delegates to post' do
      expect(result).to eq 'response'
    end
  end
end
