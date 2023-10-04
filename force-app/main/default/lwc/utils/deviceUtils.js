import FORM_FACTOR from '@salesforce/client/formFactor'

export const FORM_FACTORS = {
    SMALL: 'Small',
    MEDIUM: 'Medium',
    LARGE: 'Large'
};

export const IS_MOBILE_DEVICE =
    FORM_FACTOR === FORM_FACTORS.SMALL || FORM_FACTOR === FORM_FACTORS.MEDIUM;

export const IS_PHONE_DEVICE = () =>
    IS_MOBILE_DEVICE && (window.innerHeight / window.innerWidth > 1.6);

export const IS_TABLET_DEVICE = () =>
    IS_MOBILE_DEVICE && !(window.innerHeight / window.innerWidth > 1.6);