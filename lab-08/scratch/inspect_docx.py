import docx

doc = docx.Document('Lab 08 Worksheet .docx')
for i, child in enumerate(doc._body._element):
    tag = child.tag.split('}')[-1]
    if tag == 'p':
        p = docx.text.paragraph.Paragraph(child, doc)
        t = p.text.strip().replace('\n', ' ')
        print(f"{i:2d}: P   | {t[:80]}")
    elif tag == 'tbl':
        tbl = docx.table.Table(child, doc)
        txt = tbl.rows[0].cells[0].text.strip().replace('\n', ' ')
        print(f"{i:2d}: TBL | ({len(tbl.rows)}x{len(tbl.columns)}) | {txt[:80]}")
    else:
        print(f"{i:2d}: {tag}")
