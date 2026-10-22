import docx

doc = docx.Document(r'C:\Users\Zubi\Desktop\Comp-Arch-F26\lab-05\Lab 05 Worksheet .docx')
for i, child in enumerate(doc._body._element):
    tag = child.tag.split('}')[-1]
    if tag == 'p':
        p = docx.text.paragraph.Paragraph(child, doc)
        t = p.text.strip().replace('\n', ' ')
        if t:
            print(f"P: {t[:80]}")
    elif tag == 'tbl':
        tbl = docx.table.Table(child, doc)
        txt = tbl.rows[0].cells[0].text.strip().replace('\n', ' ')
        blips = child.xpath('.//*[local-name()="blip"]')
        print(f"TBL ({len(tbl.rows)}x{len(tbl.columns)}): text='{txt[:50]}' | images={len(blips)}")
