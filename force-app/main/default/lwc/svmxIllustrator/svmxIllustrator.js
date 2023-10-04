import { LightningElement, api } from 'lwc';
import {
    isEmptyString,
    normalizeBoolean,
    normalizeString,
} from 'c/utils';

import { images } from 'c/illustrationImage';

const DEFAULT_IMAGE_SIZE = 'small';
export default class SvmxIllustrator extends LightningElement {
    _imageSize = DEFAULT_IMAGE_SIZE;
    _textOnly = false;
    _imageName;

    /**
     * Text displayed below the illustration to describe why it is being displayed.
     * @type {string}
     */
    @api heading;

    /**
     * Text displaed below the heading to further communicate the state of the component.
     * The message body may also be replaced by passing in content via the slot named messageBody.
     * Slot content will take precedence over this property's value.
     * @type {string}
     */
    @api messageBody;

    /**
     * The identifier for the illustration image to show, in the format: `[category]:[description]`.
     * @see {@link https://www.lightningdesignsystem.com/components/illustration/|SLDS Illustration}
     *
     * @type {string}
     */
    @api
    get imageName () {
        return this._imageName;
    }

    set imageName (value) {
        this._imageName = normalizeString(value, {
            fallbackValue: 'empty',
            validValues: Object.keys(images),
        });
    }

    /**
     * Specifies the size of the illustration
     * @default small
     * @type {"small"|"large"}
     */
    @api
    get imageSize () {
        return this._imageSize;
    }
    set imageSize (value) {
        this._imageSize = normalizeString(value, {
            fallbackValue: DEFAULT_IMAGE_SIZE,
            validValues: [
                DEFAULT_IMAGE_SIZE,
                'large'
            ]
        });
    }

    /**
     * Specifies if the illustration image should be hidden.
     * @default false
     * @type {boolean}
     */
    @api
    get textOnly () {
        return this._textOnly;
    }
    set textOnly (value) {
        this._textOnly = normalizeBoolean(value);
    }

    get computedCssClass () {
        return `slds-illustration slds-illustration_${this._imageSize}`;
    }

    get hasMessageBody () {
        return !isEmptyString(this.messageBody);
    }
}