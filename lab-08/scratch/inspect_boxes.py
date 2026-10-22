import docx

doc = docx.Document('Lab 08 Worksheet .docx')

# Let's inspect the entire document structure
elements = []
for child in doc._body._element:
    tag = child.tag.split('}')[-1]
    if tag == 'p':
        p = docx.text.paragraph.Paragraph(child, doc)
        elements.append(('p', p.text.strip()))
    elif tag == 'tbl':
        tbl = docx.table.Table(child, doc)
        elements.append(('tbl', tbl))

for i, (el_type, content) in enumerate(elements):
    if el_type == 'p' and content:
        print(f"P: {content}")
    elif el_type == 'tbl':
        t = content
        print(f"--> BOX/TABLE ({len(t.rows)}x{len(t.columns)}) with content: '{t.rows[0].cells[0].text.strip()[:60]}'")
