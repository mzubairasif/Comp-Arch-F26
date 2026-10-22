import docx

doc = docx.Document('Lab 07 Worksheet.docx')

for i, child in enumerate(doc.element.body):
    tag = child.tag.split('}')[-1]
    if tag == 'p':
        p = docx.text.paragraph.Paragraph(child, doc)
        if p.text.strip():
            print(f"[{i}] P: {p.text.strip()}")
    elif tag == 'tbl':
        tbl = docx.table.Table(child, doc)
        first_text = tbl.rows[0].cells[0].text.strip().replace('\n', ' ')
        print(f"[{i}] TABLE ({len(tbl.rows)}x{len(tbl.columns)}): '{first_text[:50]}'")
