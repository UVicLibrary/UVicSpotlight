# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Etl::CustomTransforms do
  describe 'date indexing' do
    let(:date_key)  { "spotlight_upload_dc_Date_tesi" }

    describe 'with an invalid date' do
      it 'does not index extra date fields or error out' do
        expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => "N/A" }, nil))
          .to eq({ "spotlight_sort_date_tesi" => nil,
                   "spotlight_upload_dc_Date_tesi" => "N/A",
                   "spotlight_year_range_isim" => [] })
      end
    end

    describe 'with no date' do
      it 'does not index extra date fields or error out' do
        expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ "key" => "hash" }, nil))
          .to eq({ "key" => "hash" })
      end
    end

    describe 'with multiple dates' do
      it 'does not index extra date fields or error out' do
        expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => "1930; 1935-01-09" }, nil))
          .to eq({ "spotlight_sort_date_tesi" => "1930-01-01",
                   "spotlight_upload_dc_Date_tesi" => "1930; 1935-01-09",
                   "spotlight_year_range_isim" => [1930,1935] })
      end
    end

    describe 'with EDTF date' do

      context 'with a single date with year-, month-, or day-specificity' do
        context 'and date is after 1000' do
          let(:year) { "1863" }
          let(:month) { "1863-11" }
          let(:day) { "1863-11-21" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => year }, nil))
              .to eq({ "spotlight_year_range_isim" => [1863],
                       "spotlight_upload_dc_Date_tesi" => "1863",
                       "spotlight_sort_date_tesi" => "1863-01-01" })
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => month }, nil))
              .to eq({ "spotlight_year_range_isim" => [1863],
                       "spotlight_upload_dc_Date_tesi" => "1863-11",
                       "spotlight_sort_date_tesi" => "1863-11-01" })
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => day }, nil))
              .to eq({ "spotlight_year_range_isim" => [1863],
                       "spotlight_upload_dc_Date_tesi" => "1863-11-21",
                       "spotlight_sort_date_tesi" => "1863-11-21" })
          end
        end
      end

      context 'and date is before 1000' do
        let(:year) { "900" }
        let(:month) { "900-03" }
        let(:day) { "900-06-01" }

        it 'indexes the correct year range and sort date' do
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => year }, nil))
            .to eq({ "spotlight_year_range_isim" => [900],
                     "spotlight_upload_dc_Date_tesi" => "900",
                     "spotlight_sort_date_tesi" => "0900-01-01" })
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => month }, nil))
            .to eq({ "spotlight_year_range_isim" => [900],
                     "spotlight_upload_dc_Date_tesi" => "900-03",
                     "spotlight_sort_date_tesi" => "0900-03-01" })
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => day }, nil))
            .to eq({ "spotlight_year_range_isim" => [900],
                     "spotlight_upload_dc_Date_tesi" => "900-06-01",
                     "spotlight_sort_date_tesi" => "0900-06-01" })
        end
      end

      context 'with uncertain (?), approximate (~), or uncertain & approximate (%) dates' do
        let(:approx) { "1965-10~/1975-11~" }
        let(:uncertain) { "1965-10?/1970-10?" }
        let(:approx_and_uncertain) { "1965-10%/1975-11%" }

        it 'indexes the correct year range and sort date' do
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => approx }, nil))
            .to eq({ "spotlight_year_range_isim" => [*1965..1975],
                     "spotlight_upload_dc_Date_tesi" => "1965-10~/1975-11~",
                     "spotlight_sort_date_tesi" => "1965-10-01" })
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => uncertain }, nil))
            .to eq({ "spotlight_year_range_isim" => [*1965..1970],
                     "spotlight_upload_dc_Date_tesi" => "1965-10?/1970-10?",
                     "spotlight_sort_date_tesi" => "1965-10-01" })
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => approx_and_uncertain }, nil))
            .to eq({ "spotlight_year_range_isim" => [*1965..1975],
                     "spotlight_upload_dc_Date_tesi" => "1965-10%/1975-11%",
                     "spotlight_sort_date_tesi" => "1965-10-01" })
        end
      end

      context 'when date is a season' do
        let(:season) { "2011-22" }

        it 'indexes the correct year range and sort date' do
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => season }, nil))
            .to eq({ "spotlight_year_range_isim" => [2011],
                     "spotlight_upload_dc_Date_tesi" => "2011-22",
                     "spotlight_sort_date_tesi" => "2011-06-01" })
        end
      end

      context 'when date is a century' do
        context 'before 1000' do
          let(:century) { "9XX" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => century }, nil))
              .to eq({ "spotlight_year_range_isim" => [*900..999],
                       "spotlight_upload_dc_Date_tesi" => "9XX",
                       "spotlight_sort_date_tesi" => "0900-01-01" })
          end
        end

        context 'after 1000' do
          let(:century) { "19XX" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => century }, nil))
              .to eq({ "spotlight_year_range_isim" => [*1900..1999],
                       "spotlight_upload_dc_Date_tesi" => "19XX",
                       "spotlight_sort_date_tesi" => "1900-01-01" })
          end
        end
      end

      context 'when date is a decade' do
        context 'before 1000' do
          let(:decade) { "97X" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => decade }, nil))
              .to eq({ "spotlight_year_range_isim" => [*970..979],
                       "spotlight_upload_dc_Date_tesi" => "97X",
                       "spotlight_sort_date_tesi" => "0970-01-01" })
          end
        end

        context 'after 1000' do
          let(:decade) { "192X" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => decade }, nil))
              .to eq({ "spotlight_year_range_isim" => [*1920..1929],
                       "spotlight_upload_dc_Date_tesi" => "192X",
                       "spotlight_sort_date_tesi" => "1920-01-01" })
          end
        end
      end

      context 'when date is an interval' do
        let(:date) { "1989-11-09/1990-01-07" }

        it 'indexes the correct year range and sort date' do
          expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => date }, nil))
            .to eq({ "spotlight_year_range_isim" => [1989, 1990],
                     "spotlight_upload_dc_Date_tesi" => "1989-11-09/1990-01-07",
                     "spotlight_sort_date_tesi" => "1989-11-09" })
        end

        context 'that is open-ended' do
          let(:open_start) { "../1900" }
          let(:open_end) { "1900/.." }
          let(:pre_1000_start) { "950/.." }
          let(:pre_1000_end) { "../800" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => open_start }, nil))
              .to eq({ "spotlight_year_range_isim" => [1900],
                       "spotlight_upload_dc_Date_tesi" => "../1900",
                       "spotlight_sort_date_tesi" => "1900-01-01" })
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => open_end }, nil))
              .to eq({ "spotlight_year_range_isim" => [1900],
                       "spotlight_upload_dc_Date_tesi" => "1900/..",
                       "spotlight_sort_date_tesi" => "1900-01-01" })
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => pre_1000_start }, nil))
              .to eq({ "spotlight_year_range_isim" => [950],
                       "spotlight_upload_dc_Date_tesi" => "950/..",
                       "spotlight_sort_date_tesi" => "0950-01-01" })
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => pre_1000_end }, nil))
              .to eq({ "spotlight_year_range_isim" => [800],
                       "spotlight_upload_dc_Date_tesi" => "../800",
                       "spotlight_sort_date_tesi" => "0800-01-01" })
          end
        end

        context 'including date(s) before 1000' do
          let(:interval) { "950/1000" }
          let(:interval_before_1000) { "950/970" }

          it 'indexes the correct year range and sort date' do
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => interval }, nil))
              .to eq({ "spotlight_year_range_isim" => [*950..1000],
                       "spotlight_upload_dc_Date_tesi" => "950/1000",
                       "spotlight_sort_date_tesi" => "0950-01-01" })
            expect(Etl::CustomTransforms::AddDateFieldsTransform.call({ date_key => interval_before_1000 }, nil))
              .to eq({ "spotlight_year_range_isim" => [*950..970],
                       "spotlight_upload_dc_Date_tesi" => "950/970",
                       "spotlight_sort_date_tesi" => "0950-01-01" })
          end
        end
      end
    end
  end
end