package de.be.thaw;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TimePicker;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.Locale;

import de.be.thaw.model.schedule.custom.CustomEntry;
import de.be.thaw.model.schedule.custom.CustomScheduler;

/**
 * Fragment for the creation of a new custom item for the schedule.
 */

public class CreateCustomEntryActivity extends AppCompatActivity
		implements View.OnClickListener,
		CompoundButton.OnCheckedChangeListener {

	public static final String EXTRA_NAME = "CREATED_ENTRY";

	private static final String TIME_FORMAT = "HH:mm";
	private final int[] FREQUENCY = new int[]{
			CustomScheduler.DAILY,
			CustomScheduler.WEEKLY,
			CustomScheduler.BIWEEKLY
	};

	@Override
	protected void onCreate(@Nullable Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.fragment_create_custom_entry);
		initialize(findViewById(android.R.id.content));
	}

	/**
	 * Initializes listeners and default values for the view components.
	 * @param view View of the fragment
	 */
	private void initialize(View view) {
		DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.GERMAN);
		DateFormat timeFormat = new SimpleDateFormat("HH:mm", Locale.GERMAN);

		EditText ed = view.findViewById(R.id.startDate);
		ed.setOnClickListener(this);
		ed.setText(dateFormat.format(new Date()));

		ed = view.findViewById(R.id.startTime);
		ed.setOnClickListener(this);
		ed.setText(timeFormat.format(new Date()));

		ed = view.findViewById(R.id.endDate);
		ed.setOnClickListener(this);
		ed.setText(dateFormat.format(new Date()));

		ed = view.findViewById(R.id.durationTime);
		ed.setOnClickListener(this);
		ed.setText(getString(R.string.custom_entry_default_duration));

		CheckBox cb = view.findViewById(R.id.cbRecurring);
		cb.setOnCheckedChangeListener(this);

		Spinner sp = view.findViewById(R.id.spFrequency);
		ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(
				this, R.array.recurrence_frequency, R.layout.support_simple_spinner_dropdown_item);
		sp.setAdapter(adapter);

		Button bt = view.findViewById(R.id.bOkay);
		bt.setOnClickListener(this);

		bt = view.findViewById(R.id.bCancel);
		bt.setOnClickListener(this);
	}

	@Override
	public void onClick(View v) {
		switch (v.getId()) {
			case R.id.endDate:
			case R.id.startDate:
				pickDate((EditText) v);
				break;
			case R.id.startTime:
			case R.id.durationTime:
				pickTime((EditText) v);
				break;
			case R.id.bOkay:
				Intent intent = new Intent();
				intent.putExtra(EXTRA_NAME, createCustomEntry());
				setResult(Activity.RESULT_OK, intent);
			case R.id.bCancel:
				finish();
				break;
		}
	}

	/**
	 * Creates a date picker and writes the value in the given edit text.
	 * @param editText View to be filled
	 */
	private void pickDate(EditText editText) {
		DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.GERMAN);
		Calendar c = Calendar.getInstance();
		try {
			c.setTime(dateFormat.parse(editText.getText().toString()));
		} catch (ParseException e) {
			e.printStackTrace();
			c.setTime(new Date());
		}
		DatePickerDialog d =
				new DatePickerDialog(editText.getContext(),
						new FillEditText(editText),
						c.get(Calendar.YEAR),
						c.get(Calendar.MONTH),
						c.get(Calendar.DAY_OF_MONTH));
		d.show();
	}

	/**
	 * Creates a time picker and writes the value in the given edit text.
	 * @param editText View to be filled
	 */
	private void pickTime(EditText editText) {
		DateFormat timeFormat = new SimpleDateFormat(TIME_FORMAT, Locale.GERMAN);
		Date d;
		try {
			d = timeFormat.parse(editText.getText().toString());
		} catch (ParseException e) {
			e.printStackTrace();
			d = new Date();
		}
		TimePickerDialog dialog = new TimePickerDialog(editText.getContext(),
				new FillEditText(editText), d.getHours(), d.getMinutes(), true);
		dialog.show();
	}

	/**
	 * Toggles the optional recurring part of the view.
	 * @param buttonView The compound button view whose state has changed
	 * @param isChecked Visibility of the recurring part
	 */
	@Override
	public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
		int visibility = isChecked ? View.VISIBLE : View.GONE;
		findViewById(R.id.container_recurring).setVisibility(visibility);
	}

	/**
	 * Creates a custom entry object from the user input.
	 * @return Initialized CustomEntry object
	 */
	private CustomEntry createCustomEntry() {
		DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.GERMAN);
		DateFormat timeFormat = new SimpleDateFormat(TIME_FORMAT, Locale.GERMAN);
		CustomEntry ce = new CustomEntry();

		try {
			Calendar c = Calendar.getInstance();

			EditText et = findViewById(R.id.startDate);

			c.setTime(dateFormat.parse(et.getText().toString()));

			et = findViewById(R.id.startTime);
			Date d = timeFormat.parse(et.getText().toString());
			c.add(Calendar.HOUR_OF_DAY, d.getHours());
			c.add(Calendar.MINUTE, d.getMinutes());

			ce.setStart(c.getTime());

			et = findViewById(R.id.durationTime);
			d = timeFormat.parse(et.getText().toString());
			ce.setDuration(d.getHours() * 60 + d.getMinutes());

			et = findViewById(R.id.entryTitle);
			ce.setTitle(et.getText().toString());

			et = findViewById(R.id.entryDescription);
			ce.setDescription(et.getText().toString());

			et = findViewById(R.id.centry_location);
			ce.setLocation(et.getText().toString());

			CheckBox cb = findViewById(R.id.cbRecurring);
			if (cb.isChecked()) {
				Spinner sp = findViewById(R.id.spFrequency);
				ce.setCycle(FREQUENCY[sp.getSelectedItemPosition()]);
				et = findViewById(R.id.endDate);
				c.setTime(dateFormat.parse(et.getText().toString()));
				c.set(Calendar.HOUR_OF_DAY, 23);
				c.set(Calendar.MINUTE, 59);

				ce.setEnd(c.getTime());
			}
		} catch (ParseException e) {
			e.printStackTrace();
			return null;
		}

		return ce;
	}

	/**
	 * Helper class to catch the SetListener of pickers and set the EditText accordingly.
	 */
	private class FillEditText implements TimePickerDialog.OnTimeSetListener, DatePickerDialog.OnDateSetListener {
		private final EditText text;

		FillEditText(EditText text) {
			this.text = text;
		}

		@Override
		public void onDateSet(DatePicker view, int year, int month, int dayOfMonth) {
			Calendar c = Calendar.getInstance();
			c.set(year, month, dayOfMonth);
			DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.GERMAN);
			text.setText(dateFormat.format(c.getTime()));
		}

		@Override
		public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
			text.setText(String.format(Locale.GERMAN, "%02d:%02d", hourOfDay, minute));
		}
	}
}
