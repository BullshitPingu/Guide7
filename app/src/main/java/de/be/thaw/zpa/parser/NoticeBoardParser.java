package de.be.thaw.zpa.parser;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import de.be.thaw.model.noticeboard.BoardEntry;
import de.be.thaw.zpa.exception.ZPAParseException;

/**
 * Created by Benjamin Eder on 12.03.2017.
 */
public class NoticeBoardParser implements ZPAParser<BoardEntry[]> {

	public static final SimpleDateFormat DATE_PARSER = new SimpleDateFormat("dd.MM.yyyy");

	@Override
	public BoardEntry[] parse(Document doc) throws ZPAParseException {
		Elements elms = doc.getElementsByTag("tbody");

		// There should be only one tbody element so get the first otherwise throw Exception
		if (elms.size() != 1) {
			throw new ZPAParseException("None or more than one tbody element found!");
		}

		Element tbody = elms.get(0);

		// Get all Rows under tbody -> These are the Entries.
		List<BoardEntry> entries = new ArrayList<>();

		if (tbody.childNodeSize() > 0) {
			Elements htmlEntries = tbody.children();

			for (int i = 0; i < htmlEntries.size(); i++) {
				Element htmlEntry = htmlEntries.get(i);

				if (htmlEntry != null && htmlEntry.childNodeSize() > 0) {
					Elements entryItems = htmlEntry.children();

					String author = entryItems.get(0).text();
					String title = entryItems.get(1).text();

					String content = entryItems.get(2).html();

					String fromDate = entryItems.get(3).text();
					Date from = null;
					try {
						from = DATE_PARSER.parse(fromDate);
					} catch (Exception e) {
						throw new ZPAParseException(e);
					}

					String toDate = entryItems.get(4).text();
					Date to = null;
					try {
						to = DATE_PARSER.parse(toDate);
					} catch (Exception e) {
						throw new ZPAParseException(e);
					}

					entries.add(new BoardEntry(author, title, content, from, to));
				}
			}
		}

		return entries.toArray(new BoardEntry[entries.size()]);
	}

}
