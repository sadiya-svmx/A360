import DAYS from '@salesforce/label/c.Label_enumDAYS';
import MONTHS from '@salesforce/label/c.Label_enumMONTHS';
import WEEKS from '@salesforce/label/c.Label_enumWEEKS';
import YEARS from '@salesforce/label/c.Label_enumYEARS';
import Sunday from '@salesforce/label/c.Label_Sunday';
import Monday from '@salesforce/label/c.Label_Monday';
import Tuesday from '@salesforce/label/c.Label_Tuesday';
import Wednesday from '@salesforce/label/c.Label_Wednesday';
import Thursday from '@salesforce/label/c.Label_Thursday';
import Friday from '@salesforce/label/c.Label_Friday';
import Saturday from '@salesforce/label/c.Label_Saturday';
import Day from '@salesforce/label/c.Label_Day';
import January from '@salesforce/label/c.Label_January';
import February from '@salesforce/label/c.Label_February';
import March from '@salesforce/label/c.Label_March';
import April from '@salesforce/label/c.Label_April';
import May from '@salesforce/label/c.Label_May';
import June from '@salesforce/label/c.Label_June';
import July from '@salesforce/label/c.Label_July';
import August from '@salesforce/label/c.Label_August';
import September from '@salesforce/label/c.Label_September';
import October from '@salesforce/label/c.Label_October';
import November from '@salesforce/label/c.Label_November';
import December from '@salesforce/label/c.Label_December';
import Fourth from '@salesforce/label/c.Label_Fourth';
import First from '@salesforce/label/c.Label_First';
import Second from '@salesforce/label/c.Label_Second';
import Third from '@salesforce/label/c.Label_Third';
import Last from '@salesforce/label/c.Label_Last';
// Model Structure
export const ENUM_FrequencyOptions = {
    [DAYS]: DAYS,
    [WEEKS]: WEEKS,
    [MONTHS]: MONTHS,
    [YEARS]: YEARS
};
const StateKeyMapping = {
    [DAYS]: "days",
    [WEEKS]: "weeks",
    [MONTHS]: "months",
    [YEARS]: "years"
};
export const ENUM_WeekDayOptions = {
    [Sunday]: Sunday,
    [Monday]: Monday,
    [Tuesday]: Tuesday,
    [Wednesday]: Wednesday,
    [Thursday]: Thursday,
    [Friday]: Friday,
    [Saturday]: Saturday
};
const ENUM_DAYS = { ...ENUM_WeekDayOptions,
    [Day]: Day,
};

export const  ENUM_MonthScheduleOptions = {
    monthDay: "monthDay",
    dayPosition: "dayPosition",
    noOption: "noOption"
};

/** Utility: to keep it consistent when noOption value is selected in month or year */
const ENUM_BLANK = {};

const ENUM_MonthDayOptions = (() => {
    const option =  {};
    for (let i = 1; i <=31; i++ ) {
        option[i] = `${i}`;
    }
    return option;
})();

const ENUM_SetPos =  { [First]: 1, [Second]: 2, [Third]: 3, [Fourth]: 4, [Last]: -1 };

export const ENUM_YearScheduleOptions = {
    monthAndDay: "monthAndDay",
    monthAndWeekdayAndPos: "monthAndWeekdayAndPos",
    noOption: "noOption"
};

export const ENUM_TimeOptions = {
    '0': '0:00am',
    '1': '1:00am',
    '2': '2:00am',
    '3': '3:00am',
    '4': '4:00am',
    '5': '5:00am',
    '6': '6:00am',
    '7': '7:00am',
    '8': '8:00am',
    '9': '9:00am',
    '10': '10:00am',
    '11': '11:00am',
    '12': '12:00pm',
    '13': '1:00pm',
    '14': '2:00pm',
    '15': '3:00pm',
    '16': '4:00pm',
    '17': '5:00pm',
    '18': '6:00pm',
    '19': '7:00pm',
    '20': '8:00pm',
    '21': '9:00pm',
    '22': '10:00pm',
    '23': '11:00pm',
}

const ENUM_MonthOptions = {
    [January]: January,
    [February]: February,
    [March]: March,
    [April]: April,
    [May]: May,
    [June]: June,
    [July]: July,
    [August]: August,
    [September]: September,
    [October]: October,
    [November]: [November],
    [December]: December
};

export const ENUM_endScheduleOptions = { never: "never", after: "after", on: "on" }
export const ENUM_SubOptionKeyNames = {
    day: "day",
    setPos: "setPos",
    month: "month",
    weekDay: "weekDay"
};


export const BYSETPOS = { ...ENUM_SetPos };
export const BYMONTH = {
    [January]: 1,
    [February]: 2,
    [March]: 3,
    [April]: 4,
    [May]: 5,
    [June]: 6,
    [July]: 7,
    [August]: 8,
    [September]: 9,
    [October]: 10,
    [November]: 11,
    [December]: 12
};
export const BYDAY = {
    [Sunday]: "SU",
    [Monday]: "MO",
    [Tuesday]: "TU",
    [Wednesday]: "WE",
    [Thursday]: "TH",
    [Friday]: "FR",
    [Saturday]: "SA",
    [Day]: "SU,MO,TU,WE,TH,FR,SA",
};

const BYMONTHDAY = { ...ENUM_MonthDayOptions };
const FREQ = {
    [DAYS]: "DAILY",
    [WEEKS]: "WEEKLY",
    [MONTHS]: "MONTHLY",
    [YEARS]: "YEARLY"
};

const RECUR_STRING_VALUES_ENUM_COLLECTION ={
    BYSETPOS,
    BYDAY,
    BYMONTH,
    BYMONTHDAY,
    FREQ
};

const Reccurence_Constants = {
    BYMONTH: "BYMONTH",
    BYSETPOS: "BYSETPOS",
    BYDAY: "BYDAY",
    INTERVAL: "INTERVAL",
    FREQ: "FREQ",
    BYMONTHDAY: "BYMONTHDAY",
    COUNT: "COUNT",
    UNTIL: "UNTIL"
};




const seedStructure = {
    interval: {
        value: 0,
        recConstant: Reccurence_Constants.INTERVAL,
    }, // <type: number, set,get>,
    frequency: {
        options: ENUM_FrequencyOptions,
        selection: '',// ENUM_FrequencyOptions.months,
        recConstant: Reccurence_Constants.FREQ
    },
    weeks: {
        options: ENUM_WeekDayOptions,//<SUN, MON, TUE, WED, THU, FRI, SAT>
        selection: { [ENUM_WeekDayOptions[Friday]]: false },//<SUN..>,
        recConstant: Reccurence_Constants.BYDAY
    },
    months: {
        isComplex: false,
        options: ENUM_MonthScheduleOptions,   //<monthDay, dayPosition>
        selection: ENUM_MonthScheduleOptions.noOption,    // <monthDay>
        monthDay: {
            isComplex: true,
            subKeys: ["monthDay"],
            options: ENUM_MonthDayOptions, // <1 to 31>
            selection: ENUM_MonthDayOptions["1"],//<22..>
            monthDay: {
                options: ENUM_MonthDayOptions,
                selection: ENUM_MonthDayOptions["1"],
                recConstant: Reccurence_Constants.BYMONTHDAY,
            },
            recConstant: Reccurence_Constants.BYMONTHDAY,
        },
        dayPosition: {
            isComplex: true,
            subKeys: ["weekDay","setPos"], // <== use ENUM_SubOptionKeyNames
            weekDay: {
                isComplex: false,
                options: ENUM_DAYS,
                // <SUN, MON, TUE, WED, THU, FRI, SAT, WEEKDAY, WEEKENDDAY>
                selection: ENUM_DAYS[Sunday],//<SUN>
                recConstant: Reccurence_Constants.BYDAY
            },
            setPos: {
                isComplex: false,
                options: ENUM_SetPos, //<First, Second, Third, Fourth, Last>
                selection: ENUM_SetPos[First],
                recConstant: Reccurence_Constants.BYSETPOS
            }
        },
        noOption: {
            isComplex: false,
            subKeys: [],
            recConstant: null,
            options: ENUM_BLANK
        }
    },
    years: {
        isComplex: false,
        options: ENUM_YearScheduleOptions,
        selection: ENUM_YearScheduleOptions.noOption, //< monthAndWeekdayAndPos>,
        monthAndDay: {
            isComplex: true,
            subKeys: ["month","day"],
            month: {
                options: ENUM_MonthOptions, //{JAN: January,.... DEC}, 
                selection: ENUM_MonthOptions[January],
                recConstant: Reccurence_Constants.BYMONTH,
            },
            day: {
                options: ENUM_MonthDayOptions, //<1 to 31>, 
                selection: ENUM_MonthDayOptions["22"],// <22>  },
                recConstant: Reccurence_Constants.BYMONTHDAY,
            },
        },
        monthAndWeekdayAndPos: {
            isComplex: true,
            subKeys: ["month","weekDay","setPos"],
            setPos: {
                options: ENUM_SetPos,//<First, Second, Third, Fourth, Last>
                selection: ENUM_SetPos[Last],
                recConstant: Reccurence_Constants.BYSETPOS
            },
            weekDay: {
                options: ENUM_DAYS,
                //<SUN, MON, TUE, WED, THU, FRI, SAT, Day, WEEKDAY, WEEKEND DAY>
                selection: ENUM_DAYS[Day],//<Day>
                recConstant: Reccurence_Constants.BYDAY
            },
            month: {
                options: ENUM_MonthOptions, //{JAN: January,.... DEC}, 
                selection: ENUM_MonthOptions[January],
                recConstant: Reccurence_Constants.BYMONTH, //<JAN>   
            }
        },
        noOption: {
            isComplex: false,
            subKeys: [],
            recConstant: null,
            options: ENUM_BLANK
        }




    },

    endSchedule: {
        options: ENUM_endScheduleOptions,// <never, after, on>  
        selection: ENUM_endScheduleOptions.never, //
        never: true,
        after: { value: 0, recConstant: Reccurence_Constants.COUNT  },//<anynumber>    }
        on: { value: null, recConstant: Reccurence_Constants.UNTIL }//<any date>    }
    }
}

const transformToDropDownOptions = (options)=>{
    const keys = Object.keys(options);
    const drpDownOptions = keys.map((item) => {
        return ({
            label: item,
            value: item
        });
    });
    return drpDownOptions;
}

const keyValue = (objInstance, compositeKeyString) => {
    const nestedKeyList = compositeKeyString.split('.');
    const firstKey = nestedKeyList[0];
    const secondKey = nestedKeyList.slice(1).join('.');
    return (objInstance[firstKey] || {})[secondKey] || '';
};

export const getUniqueValueKey =  ( objectMap, value ) => {
    if (!value) return null;
    const entry = Object.entries(objectMap)
        .filter( itemArr => itemArr[1].toString() === value.toString() );
    return (entry.length > 0 ? (entry[0])[0] : '');
}

export default class RecurrencePatternModel {

  _dataModel = null;
  constructor () {
      this._dataModel = JSON.parse(JSON.stringify(seedStructure));
  }

  set interval (value) {
      const { interval } = this._dataModel;
      interval.value = value;
  }

  get interval () {
      const { interval } = this._dataModel;
      return interval.value;
  }

  getIntervalManager () {
      const manager = {};
      manager.setInterval= value => {this.interval = value;};
      manager.getInterval = () => this.interval;
      return manager;
  }

  /**
   * ===================== frequency manager========================
   */

  get frequencyOptions () {
      const { frequency: { options }} = this._dataModel;
      return transformToDropDownOptions(options);
  }

  get frequencyOptionSelection () {
      const { frequency: { selection }} = this._dataModel;
      return selection;
  }

  get frequencyRecConstant () {
      const { frequency: { recConstant }} = this._dataModel;
      return recConstant;
  }

  set frequencyOptionSelection (value) {
      const { frequency: { options }} = this._dataModel;
      this._dataModel.frequency.selection = options[value];
  }

  getFrequencyManager () {
      const _that = this;
      const manager = {
          get isDaySelected () {
              const { frequencyOptionSelection } = _that;
              return frequencyOptionSelection === ENUM_FrequencyOptions[DAYS];
          },
          get isWeekSelected () {
              const { frequencyOptionSelection } = _that;
              return frequencyOptionSelection === ENUM_FrequencyOptions[WEEKS];
          },
          get isMonthSelected () {
              const { frequencyOptionSelection } = _that;
              return frequencyOptionSelection === ENUM_FrequencyOptions[MONTHS];
          },

          get isYearSelected () {
              const { frequencyOptionSelection } = _that;
              return frequencyOptionSelection === ENUM_FrequencyOptions[YEARS];
          }
      };
      manager.setFrequency = (value) => {
          this.frequencyOptionSelection = value;
      };
      manager.getFrequencyOptions = () => this.frequencyOptions;
      return manager;
  }

  /**
   * ======================Week Manager============================= 
   */

  get weekOptions () {
      const { weeks: { options }} = this._dataModel;
      return transformToDropDownOptions(options);
  }

  set weekOptionSelection (value) {
      const { weeks } = this._dataModel;
      weeks.selection = value;
  }

  get weekOptionSelection () {
      const { weeks } = this._dataModel;
      return weeks.selection;
  }

  getWeekManager () {
      const manager = {};
      manager.getOptions = () => this.weekOptions;
      manager.setSelectedOption = value => {
          this.weekOptionSelection = value;
      };
      return manager;
  }

  /**
 * ================================Month Manager================================== 
 */
  get monthOptions () {
      const { months: { options }} = this._dataModel;
      return transformToDropDownOptions(options);
  }

  set monthSelectedOption (value) {
      const { months: { options }} = this._dataModel;
      this._dataModel.months.selection = options[value];
  }

  get monthSelectedOption () {
      const { months: { selection }} = this._dataModel;
      return selection;
  }

  get monthSelectionSubOptions () {
      const { months } = this._dataModel;
      const keys = Object.keys(ENUM_MonthScheduleOptions);
      const optionConfig = {};
      keys.forEach(key => {
          const selectedObject = months[key];
          const { isComplex, subKeys } = selectedObject;
          if (isComplex) {
              subKeys.forEach(subKey=>{
                  optionConfig[subKey] =
                    transformToDropDownOptions(selectedObject[subKey].options);
              });
          } else {
              optionConfig[key] =
                  transformToDropDownOptions(selectedObject.options);

          }
      });
      return optionConfig;
  }

  set monthSelectedSubOption (optionConfig) {
      const selection = this.monthSelectedOption;
      const { monthDay: monthDayKey } =ENUM_MonthScheduleOptions;
      const { months: { [selection]: selectedObject }} = this._dataModel;
      const keys = Object.keys(optionConfig);
      const subKeys = new Set([...selectedObject.subKeys]);
      const honouredKeys = keys.filter(key => subKeys.has(key));
      honouredKeys.forEach( hKey => {
          if ( hKey === monthDayKey) {
              selectedObject.selection = optionConfig[hKey];
          }
          selectedObject[hKey].selection = optionConfig[hKey];
      });
  }

  getMonthManager () {
      const manager = {};
      manager.getOptions = () => this.monthOptions;
      manager.setSelectedOption = value => {this.monthSelectedOption = value;}
      // manager.isSelectedOptionRadio =>
      manager.getSubOptions = () => this.monthSelectionSubOptions;
      manager.setSelectedSubOption = optionConfig => {this.monthSelectedSubOption = optionConfig; }
      return manager;
  }

  /**
 * ==============================Year Manager====================================
 */

  set yearSelectedOption (value) {
      const { years } = this._dataModel;
      years.selection = value;
  }
  get yearSelectedOption () {
      const { years } = this._dataModel;
      return years.selection;
  }

  set yearSelectionSubOption (optionConfig) {
      const selection = this.yearSelectedOption;
      const { years: { [selection]: selectedObject }} = this._dataModel;
      const keys = Object.keys(optionConfig);
      keys.forEach(key =>{
          if (optionConfig[key]) {
              selectedObject[key].selection = optionConfig[key];
          }
      });
  }

  get yearSelectionSubOptions () {
      const { years } = this._dataModel;
      const keys = Object.keys(ENUM_YearScheduleOptions);
      const optionConfig = {};
      keys.forEach(key => {
          const selectedObject = years[key];
          const { isComplex, subKeys } = selectedObject;
          if (isComplex) {
              //optionConfig.isComplex = true;
              subKeys.forEach(subKey=>{
                  optionConfig[subKey] =
                  transformToDropDownOptions(selectedObject[subKey].options);
              });
          } else {
              // optionConfig.complex = false;
              optionConfig[key] =
                transformToDropDownOptions(selectedObject.options);

          }
      });
      return optionConfig;
  }

  getYearManager () {
      const manager = {};
      manager.getSubOptions = () => this.yearSelectionSubOptions;
      manager.setYearSelectedOption = value => (this.yearSelectedOption = value);
      manager.setYearSubOption = optionConfig => (this.yearSelectionSubOption = optionConfig);
      return manager;
  }

  /**
 * ========================== end schedule manager
 */
  set endScheduleSelectedOption (value) {
      const { endSchedule } = this._dataModel;
      endSchedule.selection = value;
  }

  get endScheduleSelectedOption () {
      const { endSchedule } = this._dataModel;
      return endSchedule.selection;
  }

  set endScheduleSelectedOptionValue (value) {
      const selectedOptionName = this.endScheduleSelectedOption;
      const { endSchedule } = this._dataModel;
      if (selectedOptionName !== ENUM_endScheduleOptions.never) {
          endSchedule[selectedOptionName].value = value;
      }
  }

  get endScheduleSelectedOptionValue () {
      const selectedOptionName = this.endScheduleSelectedOption;
      const { endSchedule } = this._dataModel;
      if (selectedOptionName !== ENUM_endScheduleOptions.never) {
          return endSchedule[selectedOptionName].value;
      }
      return null;
  }

  getEndScheduleManager () {
      const manager = {};
      manager.setSelection = value => {this.endScheduleSelectedOption = value;};
      manager.setEndScheduleValue = value =>
      {this.endScheduleSelectedOptionValue = value;};
      return manager;
  }


  logInnerDataModel () {
      //console.log(this._dataModel);
  }

  /**
   * ====================String Generators=====================
   */

  get recurrenceStringYear () {
      const stringValueCollection = RECUR_STRING_VALUES_ENUM_COLLECTION;
      const selection = this.yearSelectedOption;
      if (selection === ENUM_YearScheduleOptions.noOption) {
          return '';
      }
      const { years: { [selection]: selectedObject }} = this._dataModel;
      const { subKeys } = selectedObject;
      return subKeys.reduce((acc,key)=>{
          const { recConstant, selection: value }= selectedObject[key];
          const recValue = keyValue(stringValueCollection, `${recConstant}.${value}`);
          return `${acc}${recConstant}=${recValue};`;
      },'');
  }

  get recurrenceStringMonth () {
      const stringValueCollection = RECUR_STRING_VALUES_ENUM_COLLECTION;
      const selection = this.monthSelectedOption;
      if (selection === ENUM_MonthScheduleOptions.noOption) {
          return '';
      }
      const { months: { [selection]: selectedObject }} = this._dataModel;
      const { subKeys } = selectedObject;
      let recurString = '';
      if (subKeys) {
          recurString = subKeys.reduce((acc,key)=>{
              const { recConstant, selection: value }= selectedObject[key];
              const recValue = keyValue(stringValueCollection, `${recConstant}.${value}`);
              return `${acc}${recConstant}=${recValue};`;
          },'');
      } else {
          const { recConstant, selection: value }= selectedObject;
          const recValue = keyValue(stringValueCollection, `${recConstant}.${value}`);
          recurString = `${recConstant}=${recValue};`
      }
      return recurString;
  }

  get recurrenceStringWeek () {
      const dayCollection   = this.weekOptionSelection;
      const { weeks: { recConstant }} = this._dataModel;
      const filteredKeys = Object.keys(dayCollection).filter( key => dayCollection[key]);
      const recValue = filteredKeys.map(key => BYDAY[key]).join(',');
      let recString = '';
      if (filteredKeys.length > 0 ) {
          recString = `${recConstant}=${recValue};`;
      }
      return recString ;
  }

  get recurrenceStringFrequency () {
      const freqSelection = this.frequencyOptionSelection;
      const stringValueCollection = RECUR_STRING_VALUES_ENUM_COLLECTION;
      const recConstant = this.frequencyRecConstant;
      const recValue = keyValue(stringValueCollection,`${recConstant}.${freqSelection}`);
      return `${recConstant}=${recValue};`;
  }

  get reccurenceStringInterval () {
      const  { interval: { recConstant }} = this._dataModel;
      const recValue = this.interval;
      return `${recConstant}=${recValue};`;
  }

  get recurrenceStringEndSchedule () {
      const selection =  this.endScheduleSelectedOption;
      const { endSchedule: { [selection]: selectedObject }} = this._dataModel;
      let recString = '';
      if (selection !== ENUM_endScheduleOptions.never) {
          const  { recConstant } = selectedObject;
          let recValue = selectedObject.value;
          if (recValue && selection === ENUM_endScheduleOptions.on) {
              recValue = `${recValue.split('-').join('')}T000000Z`;
          }
          recString = recValue ? `${recConstant}=${recValue}` : '';
      }
      return recString;
  }


  /**
 *  ======================= generate complete Recurrence String====================== 
 */
  _stringGen = {
      [DAYS]: () => '' ,
      [WEEKS]: () => this.recurrenceStringWeek,
      [MONTHS]: () => this.recurrenceStringMonth,
      [YEARS]: () => this.recurrenceStringYear
  }

  getRecurrenceString () {
      const freqSelector = this.frequencyOptionSelection;
      const {
          _stringGen: { [freqSelector]: stringGen },
          reccurenceStringInterval: interval,
          recurrenceStringFrequency: freq,
          recurrenceStringEndSchedule: endSchedule
      } = this;
      const recString = stringGen && stringGen();
      return `${freq}${interval}${recString}${endSchedule}`;
  }

  /**
   * ============================== Reverse Parsing======================
   */
  _getUniqueValueKey ( objectMap, value ) {
      if (!value) return null;
      const entry = Object.entries(objectMap)
          .filter( itemArr => itemArr[1].toString() === value.toString() );
      return (entry.length > 0 ? (entry[0])[0] : '');
  }

  _getRecTokens ( recurrenceString ) {
      const recString = recurrenceString;
      const tokens = recString.split(';');
      const tokenValuePairs = tokens.map(token => {
          return token.split('=');
      });
      const tokenValueMap = tokenValuePairs.reduce(( acc , pair) => {
          const collection = acc;
          collection[pair[0]] = pair[1];
          return collection;
      }, {});
      return tokenValueMap;
  }

  _setFrequency ( tokenValueMap ) {
      const { _getUniqueValueKey } = this;
      const { FREQ: freqValue } = tokenValueMap;
      const { FREQ: recurStringValueMap } = RECUR_STRING_VALUES_ENUM_COLLECTION;
      const selectionValueToBeSet = _getUniqueValueKey (recurStringValueMap, freqValue);
      this.frequencyOptionSelection = selectionValueToBeSet;
  }

  _setInterval ( tokenValueMap ) {
      const { INTERVAL: value } = tokenValueMap;
      this.interval = value;
  }

  _setMonth ( tokenValueMap ) {
      const { _getUniqueValueKey } = this;
      const freqSelection = this.frequencyOptionSelection;
      if (freqSelection !== ENUM_FrequencyOptions[MONTHS]) return;
      const { BYMONTHDAY: monthDay, BYDAY: weekDay, BYSETPOS: setPos } = tokenValueMap;
      if (monthDay) {
          this.monthSelectedOption = ENUM_MonthScheduleOptions.monthDay;
      } else if ( weekDay && setPos) {
          this.monthSelectedOption = ENUM_MonthScheduleOptions.dayPosition;
      } else {
          this.monthSelectedOption = ENUM_MonthScheduleOptions.noOption;
      }
      this.monthSelectedSubOption = {
          monthDay,
          setPos: _getUniqueValueKey(BYSETPOS, setPos),
          weekDay: _getUniqueValueKey(BYDAY, weekDay),
      };

  }

  _setWeek ( tokenValueMap ) {
      const { _getUniqueValueKey } = this;
      const freqSelection = this.frequencyOptionSelection;
      if (freqSelection !== ENUM_FrequencyOptions[WEEKS]) return;
      const { [Reccurence_Constants.BYDAY]: byDayString  } = tokenValueMap;
      if (!byDayString) { return ;}
      const dayMnemonicList = byDayString.split(',');
      const selectedOptions = dayMnemonicList.reduce((acc, item) => {
          const collection = acc;
          collection[_getUniqueValueKey(BYDAY,item)] = true;
          return collection;
      },{});
      this.weekOptionSelection = selectedOptions;
  }

  _setYear ( tokenValueMap ) {
      const { _getUniqueValueKey } = this;
      const freqSelection = this.frequencyOptionSelection;
      if (freqSelection !== ENUM_FrequencyOptions[YEARS]) return;
      const {
          [Reccurence_Constants.BYMONTH]: month ,
          [Reccurence_Constants.BYMONTHDAY]: day ,
          [Reccurence_Constants.BYSETPOS]: setPos,
          [Reccurence_Constants.BYDAY]: weekDay } = tokenValueMap;
      if (day) {
          this.yearSelectedOption = ENUM_YearScheduleOptions.monthAndDay;
      } else if (month && setPos && weekDay ) {
          this.yearSelectedOption = ENUM_YearScheduleOptions.monthAndWeekdayAndPos;
      } else {
          this.yearSelectedOption = ENUM_YearScheduleOptions.noOption;
      }
      this.yearSelectionSubOption = {
          month: _getUniqueValueKey(BYMONTH, month),
          setPos: _getUniqueValueKey(BYSETPOS, setPos),
          weekDay: _getUniqueValueKey(BYDAY, weekDay),
          day,
      };
  }


  _setEndSchedule (tokenValueMap) {
      const {
          [Reccurence_Constants.COUNT]: count,
          [Reccurence_Constants.UNTIL]: until
      } = tokenValueMap;
      if (!(count || until)) {
          this.endScheduleSelectedOption = ENUM_endScheduleOptions.never;
      } else if (count) {
          this.endScheduleSelectedOption = ENUM_endScheduleOptions.after;
          this.endScheduleSelectedOptionValue = count;
      } else if (until) {
          this.endScheduleSelectedOption = ENUM_endScheduleOptions.on;
          const dateStrArr = until.split('T')[0].split('');
          const year = dateStrArr.slice(0,4);
          const month =  dateStrArr.slice(4,6);
          const day = dateStrArr.slice(6);
          this.endScheduleSelectedOptionValue = [...year,'-',...month,'-',...day].join('');
      }
  }

  parseRecPatternToState (recPatternString) {
      const tokenValueMap = this._getRecTokens ( recPatternString );
      this._setFrequency (tokenValueMap);
      this._setInterval (tokenValueMap);
      this._setWeek(tokenValueMap);
      this._setMonth(tokenValueMap);
      this._setYear(tokenValueMap);
      this._setEndSchedule (tokenValueMap);
  }

  /**
   * ================================ Get Selected State ==============================
   */

  get selectedState () {
      const state = {};
      state.interval = this.interval;
      state.frequency = this.frequencyOptionSelection;
      if (!state.frequency)  return state;

      const selectedObject = this._dataModel[StateKeyMapping[state.frequency]];
      const subSelection = selectedObject && selectedObject.selection;
      if (state.frequency === MONTHS || state.frequency === YEARS) {
          state.selectedSubOption = { subSelection };
          const { subKeys = null } = selectedObject[subSelection];
          state.selectedSubOption.subKeys = subKeys;
          if (subKeys) {
              subKeys.forEach(key => {
                  state.selectedSubOption[key] = selectedObject[subSelection][key].selection;
              });
          } else {
              state.selectedSubOption.selection =  selectedObject[subSelection].selection;
          }

      } else {
          state.selection = subSelection;
      }

      state.endSchedule = {};
      state.endSchedule.selection = this.endScheduleSelectedOption;
      state.endSchedule.value = this.endScheduleSelectedOptionValue;

      return state;
  }

  /**
   * ======================= Reset State =================
   */

  resetState () {
      this._dataModel = JSON.parse(JSON.stringify(seedStructure));
  }

}