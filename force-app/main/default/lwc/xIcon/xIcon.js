import { LightningElement, api } from 'lwc';
import { classSet, normalizeString } from 'c/utils';

import SLDSIcons from '@salesforce/resourceUrl/SLDSicons';

export default class XIcon extends LightningElement {
    @api src;
    @api svgClass;
    @api size = 'medium';
    @api variant;

    isReady = false;
    svgUrl;


    @api
    get iconName () {
        return this._iconName;
    }
    set iconName (value) {
        if (value !== this._iconName) {
            this._iconName = value;
            this.isReady = false;
            const [ category, iconName ] = value.split(':');
            this.svgUrl =  `${SLDSIcons}/${category}-sprite/svg/symbols.svg#${iconName}`;
        }
    }
    _iconName = null;

    get normalizedSize () {
        return normalizeString(this.size, {
            fallbackValue: 'medium',
            validValues: ['xx-small', 'x-small', 'small', 'medium', 'large'],
        });
    }

    get normalizedVariant () {
        // NOTE: Leaving a note here because I just wasted a bunch of time
        // investigating why both 'bare' and 'inverse' are supported in
        // lightning-primitive-icon. lightning-icon also has a deprecated
        // 'bare', but that one is synonymous to 'inverse'. This 'bare' means
        // that no classes should be applied. So this component needs to
        // support both 'bare' and 'inverse' while lightning-icon only needs to
        // support 'inverse'.
        return normalizeString(this.variant, {
            fallbackValue: '',
            validValues: ['bare', 'error', 'inverse', 'warning', 'success'],
        });
    }

    get computedClass () {
        const { normalizedSize, normalizedVariant } = this;
        const classes = classSet(this.svgClass);

        if (normalizedVariant !== 'bare') {
            classes.add('slds-icon');
        }

        switch (normalizedVariant) {
            case 'error':
                classes.add('slds-icon-text-error');
                break;
            case 'warning':
                classes.add('slds-icon-text-warning');
                break;
            case 'success':
                classes.add('slds-icon-text-success');
                break;
            case 'inverse':
            case 'bare':
                break;
            default:
                // if custom icon is set, we don't want to set
                // the text-default class
                if (!this.src) {
                    classes.add('slds-icon-text-default');
                }
        }

        if (normalizedSize !== 'medium') {
            classes.add(`slds-icon_${normalizedSize}`);
        }

        return classes.toString();
    }
}