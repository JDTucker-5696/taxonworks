require 'rails_helper'

# TODO: Extract all this to a gem
describe 'Geo', group: :geo do

  context 'degrees_minutes_seconds_to_decimal_degrees' do

    context 'bad values' do

      specify 'limit check w/letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('92:5:18.1N')).to be_nil
      end

      specify 'limit check wo/letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('192:5:18.1')).to be_nil
      end
    end

    context 'NN:NN:NNA or ANN:NN:NN' do

      context 'a Northern latitude' do

        specify 'with uppercase letter front' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('N42:5:18.1')).to eq('42.088361')
        end

        specify 'with uppercase letter back' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1N')).to eq('42.088361')
        end

        specify 'with lowercase letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1n')).to eq('42.088361')
        end

        specify 'with no letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1')).to eq('42.088361')
        end

        specify 'only degrees and decimal minutes' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:30.1')).to eq('42.501667')
        end
      end

      context 'a Southern latitude' do

        specify 'with uppercase letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42:5:18.1S')).to eq('-42.088361')
        end

        specify 'with no letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42:5:18.1')).to eq('-42.088361')
        end
      end

      context 'a Western longitude' do

        specify 'with letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('88:11:43.3W')).to eq('-88.195361')
        end
      end

      specify 'without letter' do
        expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-88:11:43.3')).to eq('-88.195361')
      end

      context 'an Eastern longitude' do

        specify 'with letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('88:11:43.3E')).to eq('88.195361')
        end

        specify 'without letter' do
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('88:11:43.3')).to eq('88.195361')
        end
      end
    end

    context 'NNºNN\'NN"A or ANNºNN\'NN"' do

      context 'a Northern latitude' do

        specify 'with uppercase letter front' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('N42º5\'18.1"')).to eq('42.088361')
        end

        specify 'with uppercase letter back' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42º5\'18.1"N')).to eq('42.088361')
        end

        specify 'with no letter' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42º5\'18.1"')).to eq('42.088361')
        end
      end

      context 'a Southern latitude' do

        specify 'with uppercase letter' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('S42º5\'18.1"')).to eq('-42.088361')
        end

        specify 'with no letter' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42º5\'18.1"')).to eq('-42.088361')
        end
      end
    end

    context 'NN.NNNA or ANN.NNN' do

      context 'a Northern latitude' do

        specify 'with uppercase letter front' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('N42.1234567')).to eq('42.123457')
        end

        specify 'with no letter' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('42.1234567')).to eq('42.123457')
        end
      end

      context 'a Southern latitude' do

        specify 'with lowercase letter' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('s42.1234567')).to eq('-42.123457')
        end

        specify 'with no letter' do
          # pending 'fixing for degree symbol, tick and doubletick'
          expect(Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees('-42.1234567')).to eq('-42.123457')
        end
      end
    end
    context 'single use case for lat/long hunt_wrapper' do
      use_case = {'  N 23.23  W 44.44  ' => {'DD1A' => {method: 'text, DD1A'},
                                             'DD1B' => {piece: 'N 23.23  W 44.44',
                                                        lat: 'N 23.23',
                                                        long: 'W 44.44',
                                                        method: 'text, DD1B'},
                                             'DD2'  => {method: 'text, DD2'},
                                             'DM1'  => {method: 'text, DM1'},
                                             'DMS2' => {method: 'text, DMS2'},
                                             'DM3'  => {method: 'text, DM3'},
                                             'DMS4' => {method: 'text, DMS4'},
                                             'DD5'  => {piece: 'N 23.23  W 44.44  ',
                                                        lat: 'N 23.23  ',
                                                        long: 'W 44.44  ',
                                                        method: 'text, DD5'},
                                             'DD6'  => {method: 'text, DD6'},
                                             'DD7'  => {method: 'text, DD7'},
                                             '(;)'  => {method: '(;)'},
                                             '(,)'  => {method: '(,)'},
                                             '( )'  => {method: '( )'}}
      }
      @entry   = 0

      use_case.each { |label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          this_case = Utilities::Geo.hunt_wrapper(label)
          expect(this_case).to eq(result)
        end
      }
    end

    context 'multiple use cases for lat/long hunt_wrapper' do
      use_cases = {
        'Here is some extra text: N 23.23  W 44.44  More stuff at the end'                                                                                =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {piece: 'N 23.23  W 44.44',
                      lat: 'N 23.23',
                      long: 'W 44.44',
                      method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {piece: 'N 23.23  W 44.44  ',
                      lat: 'N 23.23  ',
                      long: 'W 44.44  ',
                      method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}},
        'Here is some extra text:,;    23.23 N  44.44 W,; More stuff at the end'                                                                          =>
          {'DD1A' => {piece: '23.23 N  44.44 W',
                      lat: '23.23 N',
                      long: '44.44 W',
                      method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {piece: '23.23 N  44.44 W',
                      lat: '23.23 N',
                      long: '44.44 W',
                      method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {piece: '23.23 N  44.44 W',
                      lat: '23.23 N',
                      long: '44.44 W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: '23.23 N  44.44 W',
                      lat: '23.23 N',
                      long: '44.44 W',
                      method: '(;)'},
           '(,)'  => {piece: '23.23 N  44.44 W',
                      lat: '23.23 N',
                      long: '44.44 W',
                      method: '(,)'},
           '( )'  => {method: '( )'}},
        "c_e_485: ARGENTINA: Jujuy, rt 9, km 1706, Finca Yala, 1500m, 24o7'2\"S65o24'13\"W, 16 Jan 2008 C.H.Dietrich, Hg vapor lights, AR13-1"            =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {piece: "24o7'2\"S65o24'13\"W",
                      lat: "24o7'2\"S",
                      long: "65o24'13\"W",
                      method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {piece: " 24o7'2\"S65o24'13\"W",
                      lat: " 24o7'2\"S65o24'13\"W",
                      method: '(,)'},
           '( )'  => {piece: "24o7'2\"S65o24'13\"W,",
                      lat: "24o7'2\"S65o24'13\"W,",
                      method: '( )'}},
        'c_e_171 prairie # 1 N 41.87734 W 89.34677 2 VIII'                                                                                                =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {piece: 'N 41.87734 W 89.34677',
                      lat: 'N 41.87734',
                      long: 'W 89.34677',
                      method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {piece: 'N 41.87734 W 89.34677 ',
                      lat: 'N 41.87734 ',
                      long: 'W 89.34677 ',
                      method: 'text, DD5'},
           'DD6'  => {piece: '1 N 41.87734 W',
                      lat: '1 N',
                      long: '41.87734 W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}},
        " 42°5'18.1\"S 88°11'43.3\"W"                                                                                                                     =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: " 42°5'18.1\"S 88°11'43.3\"W",
                      lat: " 42°5'18.1\"S 88°11'43.3\"W",
                      method: '(;)'},
           '(,)'  => {piece: " 42°5'18.1\"S 88°11'43.3\"W",
                      lat: " 42°5'18.1\"S 88°11'43.3\"W",
                      method: '(,)'},
           '( )'  => {piece: "42°5'18.1\"S 88°11'43.3\"W",
                      lat: "42°5'18.1\"S",
                      long: "88°11'43.3\"W",
                      method: '( )'}
          },
        "  S42°5'18.1\" W88o11'43.3\""                                                                                                                    =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {piece: "S42°5'18.1\" W88o11'43.3\"",
                      lat: "S42°5'18.1\"",
                      long: "W88o11'43.3\"",
                      method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: "  S42°5'18.1\" W88o11'43.3\"",
                      lat: "  S42°5'18.1\" W88o11'43.3\"",
                      method: '(;)'},
           '(,)'  => {piece: "  S42°5'18.1\" W88o11'43.3\"",
                      lat: "  S42°5'18.1\" W88o11'43.3\"",
                      method: '(,)'},
           '( )'  => {piece: "S42°5'18.1\" W88o11'43.3\"",
                      lat: "S42°5'18.1\"",
                      long: "W88o11'43.3\"",
                      method: '( )'}
          },
        "  S42o5.18' W88°11,43'"                                                                                                                          =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {piece: "S42o5.18' W88°11,43'",
                      lat: "S42o5.18'",
                      long: "W88°11,43'",
                      method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: "  S42o5.18' W88°11,43'",
                      lat: "  S42o5.18' W88°11,43'",
                      method: '(;)'},
           '(,)'  => {piece: "  S42o5.18' W88°11,43'",
                      lat: "  S42o5.18' W88°11",
                      long: "43'",
                      method: '(,)'},
           '( )'  => {piece: "S42o5.18' W88°11,43'",
                      lat: "S42o5.18'",
                      long: "W88°11,43'",
                      method: '( )'}
          },
        "42°5.18'S 88°11.43'W"                                                                                                                            =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {piece: "42°5.18'S 88°11.43'W",
                      lat: "42°5.18'S",
                      long: "88°11.43'W",
                      method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: "42°5.18'S 88°11.43'W",
                      lat: "42°5.18'S 88°11.43'W",
                      method: '(;)'},
           '(,)'  => {piece: "42°5.18'S 88°11.43'W",
                      lat: "42°5.18'S 88°11.43'W",
                      method: '(,)'},
           '( )'  => {piece: "42°5.18'S 88°11.43'W",
                      lat: "42°5.18'S",
                      long: "88°11.43'W",
                      method: '( )'}},
        'S42.18° W88.34°'                                                                                                                                 =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {piece: 'S42.18° W88.34°',
                      lat: 'S42.18°',
                      long: 'W88.34°',
                      method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: 'S42.18° W88.34°',
                      lat: 'S42.18° W88.34°',
                      method: '(;)'},
           '(,)'  => {piece: 'S42.18° W88.34°',
                      lat: 'S42.18° W88.34°',
                      method: '(,)'},
           '( )'  => {piece: 'S42.18° W88.34°',
                      lat: 'S42.18°',
                      long: 'W88.34°',
                      method: '( )'}
          },
        '42.18°S 88.43°W'                                                                                                                                 =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {piece: '42.18°S 88.43°W',
                      lat: '42.18°S',
                      long: '88.43°W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: '42.18°S 88.43°W',
                      lat: '42.18°S 88.43°W',
                      method: '(;)'},
           '(,)'  => {piece: '42.18°S 88.43°W',
                      lat: '42.18°S 88.43°W',
                      method: '(,)'},
           '( )'  => {piece: '42.18°S 88.43°W',
                      lat: '42.18°S',
                      long: '88.43°W',
                      method: '( )'}
          },
        '[-12.263, 49.398]'                                                                                                                               =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {piece: '[-12.263, 49.398]',
                      lat: '-12.263',
                      long: '49.398',
                      method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}
          },
        '[12.263, -49.398]'                                                                                                                               =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {piece: '[12.263, -49.398]',
                      lat: '12.263',
                      long: '-49.398',
                      method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}
          },
        "DDA03-001 (1) U.S.A. IL, Cook Co., Calumet, Powder Horn Lake East forest, vacuuming N41o38.395' W87o31.72' 23 V 2003 (C. Dietrich, D. Dmitriev)" =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {piece: "N41o38.395' W87o31.72'",
                      lat: "N41o38.395'",
                      long: "W87o31.72'",
                      method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {piece: "N41o38.395' W87o31.72'",
                      lat: "N41o38.395'",
                      long: "W87o31.72'",
                      method: '( )'}
          },
        "#32, USA, California, Guatay, 35 mi E San Diego, N 32o35'45\" W 116o32'27\" 5 V 2003 D. Dmitriev"                                                =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {piece: "N 32o35'45\" W 116o32'27\"",
                      lat: "N 32o35'45\"",
                      long: "W 116o32'27\"",
                      method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {piece: " 35 mi E San Diego, N 32o35'45\" W 116o32'27\" 5 V 2003 D. Dmitriev",
                      lat: ' 35 mi E San Diego',
                      long: " N 32o35'45\" W 116o32'27\" 5 V 2003 D. Dmitriev",
                      method: '(,)'},
           '( )'  => {piece: "32o35'45\" 116o32'27\"",
                      lat: "32o35'45\"",
                      long: "116o32'27\"",
                      method: '( )'}
          },
        'Hancock Agricultural; Res. Station,, Hancock; Waushara County, WI; 43.836 N 89.258 W'                                                            =>
          {'DD1A' => {piece: '43.836 N 89.258 W',
                      lat: '43.836 N',
                      long: '89.258 W',
                      method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {piece: '43.836 N 89.258 W',
                      lat: '43.836 N',
                      long: '89.258 W',
                      method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {piece: '43.836 N 89.258 W',
                      lat: '43.836 N',
                      long: '89.258 W',
                      method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: '43.836 N 89.258 W',
                      lat: '43.836 N',
                      long: '89.258 W',
                      method: '(;)'},
           '(,)'  => {piece: '43.836 N 89.258 W',
                      lat: '43.836 N',
                      long: '89.258 W',
                      method: '(,)'},
           '( )'  => {method: '( )'}
          },
        'KREIS ILLUKSTE; ♀ GEMEINDE PRODE; MANELI. 23.V 1923; LATVIA. O.CONDE'                                                                            =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {method: '(,)'},
           '( )'  => {method: '( )'}
          },
        "Kazakhstan 14.VI.2001; 100 km N. Taldy-Kurgan; Dunes around Mataj; 45 54'N, 78 43'E; M. Hauser"                                                  =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {piece: "45 54'N, 78 43'E",
                      lat: "45 54'N",
                      long: "78 43'E",
                      method: 'text, DD2'},
           'DM1'  => {piece: "45 54'N, 78 43'E",
                      lat: "45 54'N",
                      long: "78 43'E",
                      method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {piece: " 45 54'N, 78 43'E",
                      lat: " 45 54'N, 78 43'E",
                      method: '(;)'},
           '(,)'  => {piece: " 78 43'E; M. Hauser",
                      lat: " 78 43'E; M. Hauser",
                      method: '(,)'},
           '( )'  => {piece: "54'N, 43'E;",
                      lat: "54'N,",
                      long: "43'E;",
                      method: '( )'}},
        'ARGENTINA: Corrientes, P.N. Mburucuyá, 1.8 km W campgd., 80m, 28.01566o"S58.01970oW, 8 Jan 2008 C.H.Dietrich, vacuum, AR9-10'                    =>
          {'DD1A' => {method: 'text, DD1A'},
           'DD1B' => {method: 'text, DD1B'},
           'DD2'  => {method: 'text, DD2'},
           'DM1'  => {method: 'text, DM1'},
           'DMS2' => {method: 'text, DMS2'},
           'DM3'  => {method: 'text, DM3'},
           'DMS4' => {method: 'text, DMS4'},
           'DD5'  => {method: 'text, DD5'},
           'DD6'  => {method: 'text, DD6'},
           'DD7'  => {method: 'text, DD7'},
           '(;)'  => {method: '(;)'},
           '(,)'  => {piece: ' 1.8 km W campgd., 28.01566o"S58.01970oW',
                      lat: ' 1.8 km W campgd.',
                      long: ' 28.01566o"S58.01970oW',
                      method: '(,)'},
           '( )'  => {piece: '28.01566o"S58.01970oW,',
                      lat: '28.01566o"S58.01970oW,',
                      method: '( )'}}
      }
      @entry    = 0

      use_cases.each { |label, result|
        @entry += 1
        specify "case #{@entry}: #{label} should yield #{result}" do
          use_case = Utilities::Geo.hunt_wrapper(label)
          expect(use_case).to eq(result)
        end
      }

    end

    context 'multiple use cases of degrees_minutes_seconds_to_decimal_degrees' do

      use_cases = {#' 3rd ridge prairie'            => '3.0',
                   '22deg10\'34"S,'                => '-22.176111', # convert deg to º
                   '166deg30\'17"E'                => '166.504722',
                   '22dg10\'34"S,'                 => '-22.176111', # convert deg to º
                   '166dg30\'17"E'                 => '166.504722',
                   '45 54\'N'                      => '45.9',
                   '78 43\'E'                      => '78.716667',
                   '78 43\'w'                      => '-78.716667',
                   '58.0520oW,'                    => '-58.052', # tolerate the trailing comma
                   '28.01795o"S'                   => '-28.01795',
                   'N41.87734º'                    => '41.87734',
                   'W89.34677º'                    => '-89.34677',
                   ' N18º '                        => '18.0',
                   'W76.8º '                       => '-76.8',
                   '-88.241121º'                   => '-88.241121', # current test case ['-88.241121°']
                   'W88.241121º'                   => '-88.241121', # current test case ['-88.241121°']
                   'w88∫11′43.4″'                  => '-88.195389',
                   'w88∫11´43.4″'                  => '-88.195389',
                   '40º26\'46"N'                   => '40.446111', # using MAC-native symbols
                   '079º58\'56"W'                  => '-79.982222', # using MAC-native symbols
                   '40:26:46.302N'                 => '40.446195',
                   '079:58:55.903W'                => '-79.982195',
                   '40°26′46″N'                    => '40.446111',
                   '079°58′56″W'                   => '-79.982222',
                   '40d 26′ 46″ N'                 => '40.446111',
                   '40o 26′ 46″ N'                 => '40.446111',
                   '079d 58′ 56″ W'                => '-79.982222',
                   '40.446195N'                    => '40.446195',
                   '79.982195W'                    => '-79.982195',
                   '40.446195'                     => '40.446195',
                   '-79.982195'                    => '-79.982195',
                   '40° 26.7717'                   => '40.446195',
                   '-79° 58.93172'                 => '-79.982195',
                   'N40:26:46.302'                 => '40.446195',
                   'W079:58:55.903'                => '-79.982195',
                   'N40°26′46″'                    => '40.446111',
                   'W079°58′56″'                   => '-79.982222',
                   'N40d 26′ 46″'                  => '40.446111',
                   'W079d 58′ 56″'                 => '-79.982222',
                   'N40.446195'                    => '40.446195',
                   'W79.982195'                    => '-79.982195',
                   # some special characters for Dmitry
                   "  40\u02da26¥46¥S"             => '-40.446111',
                   '42∞5\'18.1"S'                  => '-42.088361',
                   'w88∞11\'43.3"'                 => '-88.195361',
                   "  42\u02da5¥18.1¥S"            => '-42.088361',
                   "  42º5'18.1'S"                 => '-42.088361',
                   "  42o5\u02b918.1\u02b9\u02b9S" => '-42.088361',
                   'w88∫11′43.3″'                  => '-88.195361',
                   # weird things that might break the converter...
                   -10                             => '-10.0',
                   '-11'                           => '-11.0',
                   'bad_data-10'                   => nil,
                   'bad_data-10.1'                 => nil,
                   'nan'                           => nil,
                   'NAN'                           => nil}

      # Dmitry's special cases of º, ', "

      # case 1:  ]  42∞5'18.1"S[
      # "\D(\d+) ?[\*∞∫o\u02DA ] ?(\d+) ?[ '¥\u02B9\u02BC\u02CA] ?(\d+[\.|,]\d+|\d+) ?[ ""\u02BA\u02EE'¥\u02B9\u02BC\u02CA]['¥\u02B9\u02BC\u02CA]? ?([nN]|[sS])"

      #  1. Non-digit => dropped
      #  2. 1 or more digits
      #     => group 0
      #  3. 0 or 1 spaces => dropped
      #  4. *, ∞, ∫, o, \u02DA, space
      #     => match for º
      #  5. 0 or 1 spaces => dropped
      #  6. 1 or more digits
      #     => group 1
      #  7. 0 or 1 spaces => dropped
      #  8. space, ', ¥, \u02B9, \u02BC, \u02CA
      #     => match for '
      #  9. 0 or 1 spaces => dropped
      # 10.
      #     a.
      #       1. 1 or more digits
      #       2. period, |, comma, => match for period
      #       3. 1 or more digits
      #     or
      #     b. 1 or more digits
      #      => group 2
      # 11. 0 or 1 spaces => dropped
      # 12. space, ", \u02BA, \u02EE, ', ¥, \u02B9, \u02BC, \u02CA, followed by 0 or 1 of ', ¥, \u02B9, \u02BC, \u02CA
      #     => match for "
      # 13. 0 or 1 spaces => dropped
      # 14. N, S, E, W, case-insensitive cardinal letter
      #     => group 3

      # case 2: ] S42∞5'18.1"[
      # "\W([nN]|[sS])\.? ?(\d+) ?[\*∞∫o\u02DA ] ?(\d+) ?[ '¥\u02B9\u02BC\u02CA] ?(\d+[\.|,]\d+|\d+) ?[ ""\u02BA\u02EE'¥\u02B9\u02BC\u02CA]['¥\u02B9\u02BC\u02CA]?[\.,;]?"

      # case 3: ] S42∞5.18'[
      # "\W([nN]|[sS])\.? ?(\d+) ?[\*∞∫o\u02DA ] ?(\d+[\.|,]\d+|\d+) ?[ '¥\u02B9\u02BC\u02CA][\.,;]?"

      # case 4: ]42∞5.18'S[
      # "\D(\d+) ?[\*∞∫o\u02DA ] ?(\d+[\.|,]\d+|\d+) ?[ '¥\u02B9\u02BC\u02CA]? ?([nN]|[sS])"
      # case 5: ]S42.18∞[
      # "\W([nN]|[sS])\.? ?(\d+[\.|,]\d+|\d+) ?[\*∞∫∫o\u02DA ][\.,;]?"

      # case 6: ]42.18∞S[
      # "\D(\d+[\.|,]\d+|\d+) ?[\*∞∫o\u02DA ] ?([nN]|[sS])"

      # case 7: ]-12.263[
      # "\D\[(-?\d+[\.|,]\d+|\-?d+)"

      @entry    = 0

      use_cases.each { |co_ordinate, result|
        @entry += 1
        specify "case #{@entry}: #{co_ordinate} should yield #{result}" do
          use_case = Utilities::Geo.degrees_minutes_seconds_to_decimal_degrees(co_ordinate)
          expect(use_case).to eq(result)
        end
      }
    end
  end

  context 'adjusting digits from params[] to 1-2-5 sequence' do
    params = {'nearby_distance' => '0', 'digit1' => '0', 'digit2' => '0'}

    specify 'garbage converts to 5000, 5, 1000' do
      params['nearby_distance'] = 'inconsistant input value'
      expect(Utilities::Geo.nearby_from_params(params)).to eq(5_000)
      expect(params['digit1']).to eq('5')
      expect(params['digit2']).to eq('1000')
    end

    specify '250 converts to 500, 5, 100' do
      params['nearby_distance'] = '250'
      expect(Utilities::Geo.nearby_from_params(params)).to eq(500)
      expect(params['digit1']).to eq('5')
      expect(params['digit2']).to eq('100')
    end

    specify '5000 converts to 5000, 5, 1000' do
      params['nearby_distance'] = '5000'
      expect(Utilities::Geo.nearby_from_params(params)).to eq(5_000)
      expect(params['digit1']).to eq('5')
      expect(params['digit2']).to eq('1000')
    end

    specify '12345 converts to 20000, 2, 10000' do
      params['nearby_distance'] = '12345'
      expect(Utilities::Geo.nearby_from_params(params)).to eq(10_000)
      expect(params['digit1']).to eq('1')
      expect(params['digit2']).to eq('10000')
    end

    specify '165432 converts to 200000, 2, 100000' do
      params['nearby_distance'] = '165432'
      expect(Utilities::Geo.nearby_from_params(params)).to eq(200_000)
      expect(params['digit1']).to eq('2')
      expect(params['digit2']).to eq('100000')
    end
  end

  context 'elevation_in_meters' do
    context 'multiple use cases' do
      use_cases = {' 12345'                => 12_345.0,
                   '3036m'                 => 3036.0,
                   '2.11km'                => 2110,
                   ' 123.45'               => 123.45,
                   ' 123 ft'               => 37.4904,
                   ' 123 ft.'              => 37.4904,
                   ' 123 feet'             => 37.4904,
                   ' 1 foot'               => 0.3048,
                   ' 123 f'                => 37.4904,
                   '   123 f.'             => 37.4904,
                   ' 123 m'                => 123.0,
                   '  123 meters'          => 123.0,
                   '     123 m.'           => 123.0,
                   '    123 km'            => 123_000.0,
                   ' 123 km.'              => 123_000.0,
                   '       123 kilometers' => 123_000.0,
                   '123 kilometer'         => 123_000.0,
                   ''                      => 0.0,
                   'sillyness'             => 0.0}

      @entry = 0

      use_cases.each { |elevation, result|
        @entry += 1
        specify "case #{@entry}: #{elevation} should yield #{result}" do
          expect(Utilities::Geo.distance_in_meters(elevation)).to eq(result)
        end
      }
    end
  end
end
