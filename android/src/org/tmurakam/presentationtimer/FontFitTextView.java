
package org.tmurakam.presentationtimer;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.TextView;

// http://stackoverflow.com/questions/2617266/how-to-adjust-text-font-size-to-fit-textview

public class FontFitTextView extends TextView {
    private final static String TAG = "PresenTimer";

    private Paint testPaint;

    private float minTextSize;

    private float maxTextSize;

    public FontFitTextView(Context context) {
        super(context);
        initialize();
    }

    public FontFitTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        initialize();
    }

    private void initialize() {
        Log.d(TAG, "FontFitTextView: initialize");
        
        testPaint = new Paint();
        testPaint.set(this.getPaint());
        // max size defaults to the initially specified text size unless it is
        // too small
        /*maxTextSize = this.getTextSize();
        if (maxTextSize < 11) {
            maxTextSize = 20;
        }*/
        maxTextSize = 300;
        minTextSize = 10;
    }

    @Override
    protected void onTextChanged(final CharSequence text, final int start, final int before,
            final int after) {
        refitText(text.toString(), this.getWidth(), this.getHeight());
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        if (w != oldw || h != oldh) {
            refitText(this.getText().toString(), w, h);
        }
    }

    /*
     * Re size the font so the specified text fits in the text box assuming the
     * text box is the specified width.
     */
    final private void refitText(String text, int width, int height) {
        if (width <= 0 || height <= 0)
            return;

        int availableWidth = width - this.getPaddingLeft() - this.getPaddingRight();
        int availableHeight = height - this.getPaddingTop() - this.getPaddingBottom();

        float max = maxTextSize;
        float min = minTextSize;
        Rect textBounds = new Rect();

        // binary search an optimal font size
        while (true) {
            float trySize = (max + min) / 2;

            testPaint.setTextSize(trySize);
            float textWidth = testPaint.measureText(text, 0, text.length());
            testPaint.getTextBounds(text, 0, text.length(), textBounds);

            if (textWidth < availableWidth && textBounds.height() < availableHeight) {
                min = trySize;    
            } else {
                max = trySize;
            }

            if (max - min < 1.0) {
                Log.d(TAG, "font size = "+ min);
                this.setTextSize(min);
                break;
            }
        }
    }
    
    // Getters and Setters
    public float getMinTextSize() {
        return minTextSize;
    }

    public void setMinTextSize(int minTextSize) {
        this.minTextSize = minTextSize;
    }

    public float getMaxTextSize() {
        return maxTextSize;
    }

    public void setMaxTextSize(int minTextSize) {
        this.maxTextSize = minTextSize;
    }
}
