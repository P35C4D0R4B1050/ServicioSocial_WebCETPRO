import { useEffect, useMemo, useState } from "react"

type Page = "dashboard" | "matriculas" | "nueva" | "especialidades" | "reportes" | "administracion" | "detalle"
type Status = "Vigente" | "Retirada" | "Anulada"
type Enrollment = {
  code: string
  first: string
  last: string
  dni: string
  birth: string
  address: string
  email: string
  phone: string
  specialty: string
  period: string
  shift: string
  entry: string
  origin: string
  amount: string
  scholarship: boolean
  agreement: string
  percentage: string
  status: Status
  date: string
}
type FormData = Omit<Enrollment, "code" | "status" | "date">
type Specialty = {
  name: string
  modality: string
  family: string
  active: boolean
}
type Offer = {
  specialty: string
  period: string
  shift: string
  teacher: string
  capacity: number
  enrolled: number
}
type UserRecord = {
  name: string
  user: string
  role: string
  status: "Activo" | "Bloqueado"
}
type Agreement = {
  name: string
  percent: number
  validity: string
  status: "Activo" | "Inactivo"
}
type DocumentRecord = {
  id: number
  date: string
  type: "Constancia de matrícula" | "Nómina de matriculados"
  format: "PDF" | "Excel"
  user: string
  detail: string
  code?: string
  rows?: Enrollment[]
}
type IconName = "grid" | "file" | "layers" | "chart" | "settings" | "plus" | "arrow" | "search" | "bell" | "chevron" | "logout" | "eye" | "edit" | "ban" | "download" | "check" | "users" | "calendar" | "clock" | "menu" | "close" | "filter" | "printer" | "shield"

const iconPaths: Record<IconName, React.ReactNode> = {
  grid: (
    <>
      <rect x="180" y="3" width="7" height="7" rx="1" />
      <rect x="14" y="3" width="7" height="7" rx="1" />
      <rect x="3" y="14" width="7" height="7" rx="1" />
      <rect x="14" y="14" width="7" height="7" rx="1" />
    </>
  ),
  file: (
    <>
      <path d="M7 3h7l5 5v13H7a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z" />
      <path d="M14 3v6h5M9 13h6M9 17h6" />
    </>
  ),
  layers: (
    <>
      <rect x="3" y="4" width="18" height="16" rx="2" />
      <path d="M3 9h18M8 4v5M8 13h8M8 17h5" />
    </>
  ),
  chart: (
    <>
      <path d="M4 20V4M4 20h17M8 16v-4M13 16V7M18 16v-7" />
    </>
  ),
  settings: (
    <>
      <path d="M4 7h16M4 12h16M4 17h16" />
      <circle cx="9" cy="7" r="2" fill="currentColor" stroke="none" />
      <circle cx="16" cy="12" r="2" fill="currentColor" stroke="none" />
      <circle cx="11" cy="17" r="2" fill="currentColor" stroke="none" />
    </>
  ),
  plus: <path d="M12 5v14M5 12h14" />,
  arrow: <path d="M5 12h14m-6-6 6 6-6 6" />,
  search: (
    <>
      <circle cx="11" cy="11" r="7" />
      <path d="m20 20-4-4" />
    </>
  ),
  bell: (
    <>
      <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9ZM10 21h4" />
    </>
  ),
  chevron: <path d="m9 18 6-6-6-6" />,
  logout: (
    <>
      <path d="M9 4H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h4M16 17l5-5-5-5M21 12H9" />
    </>
  ),
  eye: (
    <>
      <path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12Z" />
      <circle cx="12" cy="12" r="3" />
    </>
  ),
  edit: (
    <>
      <path d="m14 5 5 5M4 20l4.5-1 11-11a2.1 2.1 0 0 0-3-3l-11 11L4 20Z" />
    </>
  ),
  ban: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="m5.6 5.6 12.8 12.8" />
    </>
  ),
  download: (
    <>
      <path d="M12 3v12m-4-4 4 4 4-4M4 17v3h16v-3" />
    </>
  ),
  check: <path d="m4 12 5 5L20 6" />,
  users: (
    <>
      <circle cx="9" cy="8" r="3" />
      <path d="M3 20v-2a6 6 0 0 1 12 0v2H3ZM17 5a3 3 0 0 1 0 6M18 14a5 5 0 0 1 3 5v1h-3" />
    </>
  ),
  calendar: (
    <>
      <rect x="3" y="5" width="18" height="16" rx="2" />
      <path d="M7 3v4M17 3v4M3 10h18" />
    </>
  ),
  clock: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 7v5l3 2" />
    </>
  ),
  menu: <path d="M4 7h16M4 12h16M4 17h16" />,
  close: <path d="M5 5 19 19M19 5 5 19" />,
  filter: (
    <>
      <path d="M4 6h16M7 12h10M10 18h4" />
    </>
  ),
  printer: (
    <>
      <path d="M6 9V3h12v6M6 18H4V9h16v9h-2M6 15h12v6H6z" />
    </>
  ),
  shield: (
    <>
      <path d="m12 2 8 4v6c0 5-3 8-8 10-5-2-8-5-8-10V6l8-4Z" />
      <path d="m9 12 2 2 4-4" />
    </>
  ),
}
function Icon({
  name,
  size = 18,
  className = "",
}: {
  name: IconName
  size?: number
  className?: string
}) {
  return (
    <svg
      className={className}
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {iconPaths[name]}
    </svg>
  )
}

const specialties = [
  "Confección Textil",
  "Computación e Informática",
  "Cosmetología",
  "Gastronomía",
  "Electricidad Industrial",
  "Panadería y Pastelería",
]
const initialCatalog: Specialty[] = specialties.map((name, i) => ({
  name,
  modality:
    i % 3 === 0 ? "Título Técnico · 2 años" : "Auxiliar Técnico · 1 año",
  family: [
    "Textil y confecciones",
    "Tecnologías de la información",
    "Imagen personal",
    "Hostelería y turismo",
    "Electricidad y electrónica",
    "Industrias alimentarias",
  ][i],
  active: i !== 5,
}))
const initialOffers: Offer[] = specialties
  .slice(0, 5)
  .map((specialty, i) => ({
    specialty,
    period: "2026-I",
    shift: ["Mañana", "Tarde", "Mañana", "Noche", "Tarde"][i],
    teacher: [
      "Carmen Mendoza Rojas",
      "Luis Palomino Díaz",
      "Patricia Salazar Huamán",
      "Jorge Cárdenas Vega",
      "Elena Quispe Flores",
    ][i],
    capacity: 30,
    enrolled: [24, 18, 21, 26, 16][i],
  }))
const shifts = ["Mañana", "Tarde", "Noche"]
const initialData: Enrollment[] = [
  [
    "2026-000123",
    "María Fernanda",
    "Quispe Huamán",
    "74829163",
    "Confección Textil",
    "Mañana",
    "Vigente",
    "2026-03-18",
  ],
  [
    "2026-000122",
    "José Luis",
    "Mamani Flores",
    "70345681",
    "Computación e Informática",
    "Tarde",
    "Vigente",
    "2026-03-18",
  ],
  [
    "2026-000121",
    "Rosa Elena",
    "Condori Apaza",
    "76543219",
    "Cosmetología",
    "Mañana",
    "Vigente",
    "2026-03-17",
  ],
  [
    "2026-000120",
    "Luis Alberto",
    "Huamán Rojas",
    "72481630",
    "Gastronomía",
    "Noche",
    "Retirada",
    "2026-03-17",
  ],
  [
    "2026-000119",
    "Carmen Pilar",
    "Cárdenas Soto",
    "71829364",
    "Electricidad Industrial",
    "Tarde",
    "Vigente",
    "2026-03-16",
  ],
  [
    "2026-000118",
    "Diego Armando",
    "Torres Paredes",
    "75612348",
    "Panadería y Pastelería",
    "Mañana",
    "Anulada",
    "2026-03-15",
  ],
  [
    "2026-000117",
    "Ana Lucía",
    "Salazar Vega",
    "73928416",
    "Computación e Informática",
    "Noche",
    "Vigente",
    "2026-03-14",
  ],
  [
    "2026-000116",
    "Pedro Miguel",
    "Chávez Ramos",
    "71456382",
    "Gastronomía",
    "Tarde",
    "Vigente",
    "2026-03-13",
  ],
].map(([code, first, last, dni, specialty, shift, status, date]) => ({
  code,
  first,
  last,
  dni,
  birth: "2002-07-12",
  address: "Ayacucho, Perú",
  email: "",
  phone: "987654321",
  specialty,
  period: "2026-I",
  shift,
  entry: "Nuevo",
  origin: "",
  amount: "150",
  scholarship: false,
  agreement: "",
  percentage: "",
  status: status as Status,
  date,
}))
const emptyForm: FormData = {
  first: "",
  last: "",
  dni: "",
  birth: "",
  address: "",
  email: "",
  phone: "",
  specialty: "",
  period: "2026-I",
  shift: "",
  entry: "Nuevo",
  origin: "",
  amount: "150",
  scholarship: false,
  agreement: "",
  percentage: "",
}
const dateDisplay = (date: string) => {
  const [y, m, d] = date.split("-")
  return `${d}/${m}/${y}`
}
const fullName = (e: Enrollment) => `${e.first} ${e.last}`
function Logo({ light = false }: { light?: boolean }) {
  return (
    <div className={`brand ${light ? "brand-light" : ""}`}>
      <div className="brand-mark">
        <span>CJ</span>
        <span>LA</span>
      </div>
      <div className="brand-copy">
        <strong>CJLA</strong>
        <span>CETPRO Joaquín López Antay</span>
      </div>
    </div>
  )
}
function Badge({ status }: { status: Status }) {
  return (
    <span className={`badge badge-${status.toLowerCase()}`}>
      <span className="badge-dot" />
      {status}
    </span>
  )
}
function SectionHeading({
  kicker,
  title,
  description,
}: {
  kicker: string
  title: string
  description?: string
}) {
  return (
    <div className="page-heading">
      <div>
        <div className="eyebrow">{kicker}</div>
        <h1>{title}</h1>
        {description && <p>{description}</p>}
      </div>
    </div>
  )
}
function Field({
  label,
  required = false,
  children,
  hint,
}: {
  label: string
  required?: boolean
  children: React.ReactNode
  hint?: string
}) {
  return (
    <label className="field">
      <span className="field-label">
        {label}
        {required && <span className="required"> *</span>}
      </span>
      {children}
      {hint && <span className="field-hint">{hint}</span>}
    </label>
  )
}

// Shared institutional palette for downloadable documents, independent of screen CSS.
const documentTheme = {
  primary: "1F3864",
  accent: "2E5395",
  background: "F8FAFD",
  green: "3F7F6F",
  border: "E7EBF1",
}
const money = (value: string | number) =>
  new Intl.NumberFormat("es-PE", { style: "currency", currency: "PEN" }).format(
    Number(value) || 0,
  )
const exportScope = (rows: Enrollment[]) => {
  const distinct = (key: "period" | "specialty" | "shift" | "status") =>
    [...new Set(rows.map((e) => e[key]))].join(", ") || "Sin registros"
  return `Periodo: ${distinct("period")} · Especialidad: ${distinct("specialty")} · Turno: ${distinct("shift")} · Estado: ${distinct("status")}`
}
const exportStamp = () => new Date().toISOString().slice(0, 10)

async function downloadWorkbook(enrollments: Enrollment[], user: string) {
  const { default: ExcelJS } = await import("exceljs")
  const workbook = new ExcelJS.Workbook()
  workbook.creator = user
  workbook.company = "CETPRO Joaquín López Antay"
  workbook.created = new Date()
  workbook.title = "Nómina de matriculados"
  const headers = [
    "Código",
    "DNI",
    "Nombres",
    "Apellidos",
    "Nacimiento",
    "Dirección",
    "Correo",
    "Teléfono",
    "Especialidad",
    "Periodo",
    "Turno",
    "Tipo de ingreso",
    "Origen",
    "Estado",
    "Fecha de matrícula",
    "Monto registrado (S/)",
    "Beca / exoneración",
    "Convenio",
    "Descuento",
  ]
  const sheet = workbook.addWorksheet("Matrículas")
  sheet.columns = [
    19, 13, 25, 25, 16, 35, 30, 16, 34, 13, 14, 19, 30, 15, 21, 23, 23, 42, 16,
  ].map((width) => ({ width }))
  const title = (target: typeof sheet, columns: number, subtitle: string) => {
    ;[
      "CETPRO Joaquín López Antay",
      subtitle,
      `Emisión: ${new Date().toLocaleString("es-PE")} · Responsable: ${user}`,
      exportScope(enrollments),
    ].forEach((text, i) => {
      target.mergeCells(i + 1, 1, i + 1, columns)
      const cell = target.getCell(i + 1, 1)
      cell.value = text
      cell.fill = {
        type: "pattern",
        pattern: "solid",
        fgColor: {
          argb: i < 2 ? documentTheme.primary : documentTheme.background,
        },
      }
      cell.font = {
        name: "Calibri",
        size: i === 0 ? 18 : 11,
        bold: i < 2,
        color: { argb: i < 2 ? "FFFFFF" : documentTheme.primary },
      }
      cell.alignment = { vertical: "middle", wrapText: true }
      target.getRow(i + 1).height = i === 3 ? 42 : 28
    })
    target.views = [{ state: "frozen", ySplit: 6 }]
    target.pageSetup = {
      paperSize: 9,
      orientation: "landscape",
      fitToPage: true,
      fitToWidth: 1,
      fitToHeight: 0,
      printTitlesRow: "1:6",
    }
    target.headerFooter.oddFooter =
      "&LCETPRO Joaquín López Antay · Uso interno&RPágina &P de &N"
  }
  const styleTable = (
    target: typeof sheet,
    lastRow: number,
    columns: number,
  ) => {
    target.getRow(6).height = 32
    for (let r = 6; r <= lastRow; r++) {
      const row = target.getRow(r)
      if (r > 6) row.height = 34
      for (let c = 1; c <= columns; c++) {
        const cell = row.getCell(c)
        cell.font = {
          name: "Calibri",
          size: 11,
          bold: r === 6,
          color: { argb: r === 6 ? "FFFFFF" : documentTheme.primary },
        }
        cell.fill = {
          type: "pattern",
          pattern: "solid",
          fgColor: {
            argb:
              r === 6
                ? documentTheme.accent
                : r % 2
                  ? "FFFFFF"
                  : documentTheme.background,
          },
        }
        cell.alignment = { vertical: "middle", wrapText: true }
        cell.border = {
          bottom: { style: "thin", color: { argb: documentTheme.border } },
        }
      }
    }
    target.autoFilter = {
      from: { row: 6, column: 1 },
      to: { row: Math.max(6, lastRow), column: columns },
    }
    target.pageSetup.printArea = `A1:${target.getColumn(columns).letter}${lastRow + 2}`
  }
  title(sheet, headers.length, "NÓMINA DE MATRICULADOS · Ayacucho, Perú")
  sheet.getRow(6).values = headers
  enrollments.forEach((e, index) => {
    const row = sheet.getRow(index + 7)
    row.values = [
      e.code,
      e.dni,
      e.first,
      e.last,
      e.birth ? new Date(`${e.birth}T00:00:00Z`) : "",
      e.address,
      e.email,
      e.phone,
      e.specialty,
      e.period,
      e.shift,
      e.entry,
      e.origin,
      e.status,
      new Date(`${e.date}T00:00:00Z`),
      Number(e.amount) || 0,
      e.scholarship ? "Sí" : "No",
      e.scholarship ? e.agreement : "",
      e.scholarship ? (Number(e.percentage) || 0) / 100 : 0,
    ]
    ;[1, 2, 8].forEach((c) => {
      row.getCell(c).numFmt = "@"
    })
    ;[5, 15].forEach((c) => {
      row.getCell(c).numFmt = "dd/mm/yyyy"
    })
    row.getCell(16).numFmt = '"S/ "#,##0.00'
    row.getCell(19).numFmt = "0%"
  })
  const lastRow = enrollments.length + 6
  styleTable(sheet, lastRow, headers.length)
  sheet.getCell(lastRow + 2, 15).value = "TOTAL REGISTRADO"
  sheet.getCell(lastRow + 2, 16).value = enrollments.length
    ? {
        formula: `SUM(P7:P${lastRow})`,
        result: enrollments.reduce((total, e) => total + Number(e.amount), 0),
      }
    : 0
  sheet.getCell(lastRow + 2, 16).numFmt = '"S/ "#,##0.00'
  sheet.getRow(lastRow + 2).font = {
    bold: true,
    color: { argb: documentTheme.green },
  }

  const summary = workbook.addWorksheet("Resumen por especialidad")
  summary.columns = [40, 15, 15, 15, 15, 26].map((width) => ({ width }))
  title(summary, 6, "RESUMEN POR ESPECIALIDAD · Registros exportados")
  summary.getRow(6).values = [
    "Especialidad",
    "Total",
    "Vigentes",
    "Retiradas",
    "Anuladas",
    "Monto registrado (S/)",
  ]
  const names = [...new Set(enrollments.map((e) => e.specialty))]
  names.forEach((name, index) => {
    const rows = enrollments.filter((e) => e.specialty === name)
    const row = summary.getRow(index + 7)
    row.values = [
      name,
      rows.length,
      rows.filter((e) => e.status === "Vigente").length,
      rows.filter((e) => e.status === "Retirada").length,
      rows.filter((e) => e.status === "Anulada").length,
      rows.reduce((total, e) => total + Number(e.amount), 0),
    ]
    row.getCell(6).numFmt = '"S/ "#,##0.00'
  })
  styleTable(summary, names.length + 6, 6)
  const total = summary.getRow(names.length + 8)
  total.getCell(1).value = "TOTAL"
  for (let c = 2; c <= 6; c++) {
    const letter = summary.getColumn(c).letter
    total.getCell(c).value = names.length
      ? {
          formula: `SUM(${letter}7:${letter}${names.length + 6})`,
          result: names.reduce((sum, _, index) => sum + Number(summary.getCell(index + 7, c).value), 0),
        }
      : 0
  }
  total.font = { bold: true, color: { argb: documentTheme.green } }
  total.getCell(6).numFmt = '"S/ "#,##0.00'
  const buffer = await workbook.xlsx.writeBuffer()
  const url = URL.createObjectURL(
    new Blob([new Uint8Array(buffer)], {
      type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    }),
  )
  const link = document.createElement("a")
  link.href = url
  link.download = `nomina-matriculas-${exportStamp()}.xlsx`
  document.body.appendChild(link)
  link.click()
  link.remove()
  window.setTimeout(() => URL.revokeObjectURL(url), 1000)
}

async function downloadPdf(
  kind: "constancia" | "nomina",
  enrollment: Enrollment | undefined,
  rows: Enrollment[],
  user: string,
) {
  const [{ jsPDF }, { autoTable }] = await Promise.all([
    import("jspdf"),
    import("jspdf-autotable"),
  ])
  const doc = new jsPDF({
    orientation: kind === "nomina" ? "landscape" : "portrait",
    unit: "mm",
    format: "a4",
  })
  const width = doc.internal.pageSize.getWidth()
  const height = doc.internal.pageSize.getHeight()
  const title =
    kind === "constancia"
      ? "Ficha / constancia de matrícula"
      : "Nómina de matriculados"
  doc.setProperties({
    title,
    author: user,
    subject: "CETPRO Joaquín López Antay",
  })
  const header = () => {
    doc.setFillColor(`#${documentTheme.primary}`)
    doc.roundedRect(14, 12, 18, 18, 2, 2, "F")
    doc.setTextColor("#FFFFFF")
    doc.setFont("helvetica", "bold")
    doc.setFontSize(9)
    doc.text("CJLA", 23, 23, { align: "center" })
    doc.setTextColor(`#${documentTheme.primary}`)
    doc.setFontSize(15)
    doc.text("CETPRO “Joaquín López Antay”", 37, 19)
    doc.setFont("helvetica", "normal")
    doc.setFontSize(9)
    doc.text("Educación técnico-productiva · Ayacucho, Perú", 37, 25)
    doc.setDrawColor(`#${documentTheme.border}`)
    doc.line(14, 34, width - 14, 34)
    doc.setFont("helvetica", "bold")
    doc.setFontSize(12)
    doc.text(title, 14, 41)
  }
  let endY = 50
  if (kind === "constancia" && enrollment) {
    const e = enrollment
    const group = (label: string) => [
      {
        content: label,
        colSpan: 2,
        styles: {
          fillColor: `#${documentTheme.accent}`,
          textColor: "#FFFFFF",
          fontStyle: "bold" as const,
        },
      },
    ]
    autoTable(doc, {
      startY: 49,
      margin: { top: 49, bottom: 22, left: 14, right: 14 },
      theme: "grid",
      styles: {
        font: "helvetica",
        fontSize: 9,
        cellPadding: 2.4,
        lineColor: `#${documentTheme.border}`,
        textColor: `#${documentTheme.primary}`,
        overflow: "linebreak",
      },
      columnStyles: { 0: { cellWidth: 48, fontStyle: "bold" } },
      body: [
        group("01 · DATOS DEL ESTUDIANTE"),
        ["Nombres y apellidos", fullName(e)],
        ["DNI", e.dni],
        ["Fecha de nacimiento", dateDisplay(e.birth)],
        ["Dirección", e.address || "No registrada"],
        [
          "Teléfono / correo",
          `${e.phone || "No registrado"} / ${e.email || "No registrado"}`,
        ],
        group("02 · DATOS DE MATRÍCULA"),
        ["Código / fecha", `${e.code} / ${dateDisplay(e.date)}`],
        ["Especialidad", e.specialty],
        ["Periodo / turno", `${e.period} / ${e.shift}`],
        ["Ingreso / origen", `${e.entry} / ${e.origin || "No aplica"}`],
        ["Estado", e.status],
        group("03 · INFORMACIÓN ECONÓMICA"),
        ["Monto registrado", money(e.amount)],
        ["Beca / exoneración", e.scholarship ? "Sí" : "No"],
        ["Convenio", e.scholarship ? e.agreement : "No aplica"],
        ["Descuento", e.scholarship ? `${e.percentage}%` : "No aplica"],
      ],
      rowPageBreak: "avoid",
      didDrawPage: (hook) => {
        header()
        endY = hook.cursor?.y || 50
      },
    })
    const note =
      e.status === "Vigente"
        ? `La institución deja constancia de la matrícula vigente del estudiante en el periodo ${e.period}.`
        : `Registro con estado ${e.status.toLowerCase()}. Este documento no acredita una matrícula vigente.`
    const lines = doc.splitTextToSize(note, width - 28)
    const noteHeight = lines.length * 4.5
    if (endY + noteHeight + 40 > height - 22) {
      doc.addPage()
      header()
      endY = 49
    }
    doc.setFont("helvetica", "normal")
    doc.setFontSize(9)
    doc.setTextColor(`#${documentTheme.primary}`)
    doc.text(lines, 14, endY + 9)
    const signatureY = endY + noteHeight + 29
    doc.setDrawColor(`#${documentTheme.green}`)
    doc.line(20, signatureY, 85, signatureY)
    doc.line(width - 85, signatureY, width - 20, signatureY)
    doc.setFontSize(8)
    doc.text("Firma del estudiante", 52.5, signatureY + 5, { align: "center" })
    doc.text("Firma y sello institucional", width - 52.5, signatureY + 5, {
      align: "center",
    })
  } else {
    const scope = doc.splitTextToSize(exportScope(rows), width - 28)
    header()
    doc.setFont("helvetica", "normal")
    doc.setFontSize(8)
    doc.text(scope, 14, 49)
    const tableTop = 53 + scope.length * 4
    autoTable(doc, {
      startY: tableTop,
      margin: { top: 48, bottom: 22, left: 14, right: 14 },
      head: [
        [
          "Código",
          "DNI",
          "Estudiante",
          "Especialidad",
          "Periodo",
          "Turno",
          "Estado",
          "Fecha",
          "Monto (S/)",
        ],
      ],
      body: rows.map((e) => [
        e.code,
        e.dni,
        fullName(e),
        e.specialty,
        e.period,
        e.shift,
        e.status,
        dateDisplay(e.date),
        money(e.amount),
      ]),
      styles: {
        font: "helvetica",
        fontSize: 8,
        cellPadding: 2.5,
        textColor: `#${documentTheme.primary}`,
      },
      headStyles: { fillColor: `#${documentTheme.accent}` },
      alternateRowStyles: { fillColor: `#${documentTheme.background}` },
      columnStyles: { 8: { halign: "right" } },
      rowPageBreak: "avoid",
      didDrawPage: (hook) => {
        header()
        endY = hook.cursor?.y || tableTop
      },
    })
    if (endY + 12 > height - 22) {
      doc.addPage()
      header()
      endY = 49
    }
    doc.setFont("helvetica", "bold")
    doc.setTextColor(`#${documentTheme.green}`)
    doc.setFontSize(10)
    doc.text(
      `${rows.length} registros · Monto registrado: ${money(rows.reduce((total, e) => total + Number(e.amount), 0))}`,
      14,
      endY + 10,
    )
  }
  const pages = doc.getNumberOfPages()
  for (let page = 1; page <= pages; page++) {
    doc.setPage(page)
    doc.setFont("helvetica", "normal")
    doc.setFontSize(8)
    doc.setTextColor(`#${documentTheme.primary}`)
    doc.setDrawColor(`#${documentTheme.border}`)
    doc.line(14, height - 18, width - 14, height - 18)
    doc.text(
      `Emisión: ${new Date().toLocaleString("es-PE")} · Uso interno`,
      14,
      height - 13,
    )
    doc.text(`Página ${page} de ${pages}`, width - 14, height - 13, {
      align: "right",
    })
    doc.text(
      doc.splitTextToSize(`Responsable: ${user}`, width - 55)[0],
      14,
      height - 8,
    )
  }
  doc.save(
    kind === "constancia"
      ? `ficha-matricula-${enrollment?.code}.pdf`
      : `nomina-matriculas-${exportStamp()}.pdf`,
  )
}

export default function App() {
  const [role, setRole] = useState<"matricula" | "directivo" | "admin" | null>(
    null,
  )
  const [currentUser, setCurrentUser] = useState<UserRecord | null>(null)
  const [page, setPage] = useState<Page>("dashboard")
  const [loginUser, setLoginUser] = useState("")
  const [loginPassword, setLoginPassword] = useState("")
  const [loginError, setLoginError] = useState(false)
  const [data, setData] = useState<Enrollment[]>(initialData)
  const [form, setForm] = useState<FormData>(emptyForm)
  const [editingCode, setEditingCode] = useState<string | null>(null)
  const [selectedCode, setSelectedCode] = useState<string | null>(null)
  const [formError, setFormError] = useState("")
  const [confirmed, setConfirmed] = useState<string | null>(null)
  const [filterSpecialty, setFilterSpecialty] = useState("")
  const [filterShift, setFilterShift] = useState("")
  const [filterStatus, setFilterStatus] = useState("")
  const [query, setQuery] = useState("")
  const [listPage, setListPage] = useState(1)
  const [mobileOpen, setMobileOpen] = useState(false)
  const [catalog, setCatalog] = useState<Specialty[]>(initialCatalog)
  const [offers, setOffers] = useState<Offer[]>(initialOffers)
  const [users, setUsers] = useState<UserRecord[]>([
    {
      name: "Elena Vargas Rojas",
      user: "matricula",
      role: "Matrícula",
      status: "Activo",
    },
    {
      name: "Ricardo Palomino Díaz",
      user: "directivo",
      role: "Directivo",
      status: "Activo",
    },
    {
      name: "María Torres Sánchez",
      user: "admin",
      role: "Administrador",
      status: "Activo",
    },
  ])
  const [agreements, setAgreements] = useState<Agreement[]>([
    {
      name: "Municipalidad Provincial de Huamanga",
      percent: 25,
      validity: "01/03/2026 – 31/12/2026",
      status: "Activo",
    },
    {
      name: "Dirección Regional de Educación",
      percent: 40,
      validity: "01/01/2026 – 31/12/2026",
      status: "Activo",
    },
  ])
  const [documents, setDocuments] = useState<DocumentRecord[]>([
    {
      id: 1,
      date: "18/03/2026, 10:42",
      type: "Nómina de matriculados",
      format: "Excel",
      user: "Ricardo Palomino Díaz",
      detail: "5 matriculados",
      rows: initialData.filter((e) => e.status === "Vigente").slice(0, 5),
    },
    {
      id: 2,
      date: "18/03/2026, 09:18",
      type: "Constancia de matrícula",
      format: "PDF",
      user: "Elena Vargas Rojas",
      detail: "2026-000123",
      code: "2026-000123",
    },
    {
      id: 3,
      date: "17/03/2026, 16:30",
      type: "Nómina de matriculados",
      format: "PDF",
      user: "Ricardo Palomino Díaz",
      detail: "6 matriculados",
      rows: initialData.filter((e) => e.status === "Vigente"),
    },
  ])
  const specialtyNames = catalog.filter((s) => s.active).map((s) => s.name)
  const selected = data.find((e) => e.code === selectedCode)
  const filtered = useMemo(
    () =>
      data.filter(
        (e) =>
          (!filterSpecialty || e.specialty === filterSpecialty) &&
          (!filterShift || e.shift === filterShift) &&
          (!filterStatus || e.status === filterStatus) &&
          (!query ||
            `${e.code} ${e.dni} ${fullName(e)}`
              .toLowerCase()
              .includes(query.toLowerCase())),
      ),
    [data, filterSpecialty, filterShift, filterStatus, query],
  )
  const pages = Math.max(1, Math.ceil(filtered.length / 5))
  const shown = filtered.slice(
    (Math.min(listPage, pages) - 1) * 5,
    Math.min(listPage, pages) * 5,
  )
  useEffect(() => {
    setListPage(1)
  }, [filterSpecialty, filterShift, filterStatus, query])

  function navigate(next: Page) {
    setPage(next)
    setMobileOpen(false)
    setConfirmed(null)
    setFormError("")
  }
  function startNew() {
    setForm(emptyForm)
    setEditingCode(null)
    navigate("nueva")
  }
  function edit(e: Enrollment) {
    if (role === "directivo") return
    const { code: _code, status: _status, date: _date, ...rest } = e
    void _code
    void _status
    void _date
    setForm(rest)
    setEditingCode(e.code)
    navigate("nueva")
  }
  function view(e: Enrollment) {
    setSelectedCode(e.code)
    navigate("detalle")
  }
  function annul(e: Enrollment) {
    if (
      role !== "directivo" &&
      e.status !== "Anulada" &&
      window.confirm(
        `¿Anular la matrícula ${e.code} de ${fullName(e)}? Esta acción cambiará su estado a Anulada.`,
      )
    )
      setData((prev) =>
        prev.map((row) =>
          row.code === e.code ? { ...row, status: "Anulada" } : row,
        ),
      )
  }
  async function print(
    kind: "constancia" | "nomina",
    code?: string,
    rows?: Enrollment[],
    record = true,
  ) {
    const enrollment = data.find((e) => e.code === code)
    if (kind === "constancia" && !enrollment) {
      window.alert("No se encontró la matrícula para generar el documento.")
      return
    }
    try {
      await downloadPdf(kind, enrollment, rows || [], currentUser?.name || "")
      if (record)
        setDocuments((prev) => [
          {
            id: Date.now(),
            date: new Date().toLocaleString("es-PE"),
            type:
              kind === "constancia"
                ? "Constancia de matrícula"
                : "Nómina de matriculados",
            format: "PDF",
            user: currentUser?.name || "",
            detail:
              kind === "constancia"
                ? code || ""
                : `${rows?.length || 0} matriculados`,
            code,
            rows: rows?.map((e) => ({ ...e })),
          },
          ...prev,
        ])
    } catch {
      window.alert("No se pudo generar el PDF. Inténtalo nuevamente.")
    }
  }
  function update<K extends keyof FormData>(key: K, value: FormData[K]) {
    setForm((prev) => ({ ...prev, [key]: value }))
    setFormError("")
  }
  function submitEnrollment(ev: React.FormEvent) {
    ev.preventDefault()
    const birth = new Date(`${form.birth}T00:00:00`)
    const today = new Date()
    const age =
      today.getFullYear() -
      birth.getFullYear() -
      (today.getMonth() < birth.getMonth() ||
      (today.getMonth() === birth.getMonth() &&
        today.getDate() < birth.getDate())
        ? 1
        : 0)
    if (!form.birth || Number.isNaN(age) || age < 16) {
      setFormError(
        "El estudiante debe tener al menos 16 años para matricularse.",
      )
      return
    }
    if (!/^\d{8}$/.test(form.dni)) {
      setFormError("El DNI debe tener exactamente 8 dígitos.")
      return
    }
    if (
      data.some(
        (e) =>
          e.dni === form.dni &&
          e.code !== editingCode &&
          e.status !== "Anulada",
      )
    ) {
      setFormError("Este DNI ya tiene una matrícula registrada.")
      return
    }
    if (form.entry !== "Nuevo" && !form.origin.trim()) {
      setFormError("Indica la especialidad o institución de origen.")
      return
    }
    if (
      form.scholarship &&
      (!form.agreement ||
        !form.percentage ||
        Number(form.percentage) < 1 ||
        Number(form.percentage) > 50)
    ) {
      setFormError(
        "Selecciona un convenio e indica un porcentaje entre 1% y 50%.",
      )
      return
    }
    if (
      form.scholarship &&
      Number(form.percentage) >
        (agreements.find((a) => a.name === form.agreement)?.percent || 50)
    ) {
      setFormError("El descuento supera el porcentaje máximo de este convenio.")
      return
    }
    const code =
      editingCode ||
      `2026-${String(Math.max(...data.map((e) => Number(e.code.split("-")[1])), 0) + 1).padStart(6, "0")}`
    const row: Enrollment = {
      ...form,
      origin: form.entry === "Nuevo" ? "" : form.origin,
      agreement: form.scholarship ? form.agreement : "",
      percentage: form.scholarship ? form.percentage : "",
      code,
      status: editingCode
        ? data.find((e) => e.code === editingCode)?.status || "Vigente"
        : "Vigente",
      date: editingCode
        ? data.find((e) => e.code === editingCode)?.date ||
          new Date().toISOString().slice(0, 10)
        : new Date().toISOString().slice(0, 10),
    }
    setData((prev) =>
      editingCode
        ? prev.map((e) => (e.code === editingCode ? row : e))
        : [row, ...prev],
    )
    setConfirmed(code)
    setEditingCode(null)
    window.scrollTo({ top: 0, behavior: "smooth" })
  }
  function login(ev: React.FormEvent) {
    ev.preventDefault()
    const account = users.find(
      (person) =>
        person.user === loginUser.trim().toLowerCase() &&
        person.status === "Activo",
    )
    if (account && loginPassword === "CJLA2026") {
      const nextRole =
        account.role === "Directivo"
          ? "directivo"
          : account.role === "Administrador"
            ? "admin"
            : "matricula"
      setCurrentUser(account)
      setRole(nextRole)
      setPage(nextRole === "directivo" ? "reportes" : "dashboard")
      setLoginError(false)
    } else setLoginError(true)
  }
  function logout() {
    setRole(null)
    setCurrentUser(null)
    setLoginPassword("")
    setLoginError(false)
    setPage("dashboard")
  }
  async function exportExcel(enrollments: Enrollment[], record = true) {
    try {
      await downloadWorkbook(enrollments, currentUser?.name || "")
      if (record)
        setDocuments((prev) => [
          {
            id: Date.now(),
            date: new Date().toLocaleString("es-PE"),
            type: "Nómina de matriculados",
            format: "Excel",
            user: currentUser?.name || "",
            detail: `${enrollments.length} matriculados`,
            rows: enrollments.map((e) => ({ ...e })),
          },
          ...prev,
        ])
    } catch {
      window.alert("No se pudo generar el Excel. Inténtalo nuevamente.")
    }
  }

  if (!role)
    return (
      <div className="login-screen">
        <div className="login-side">
          <div className="login-side-inner">
            <Logo light />
            <div className="login-side-bottom">
              <div className="login-rule" />
              <span className="login-overline">
                SISTEMA INSTITUCIONAL · 2026
              </span>
              <h1>
                Una gestión académica
                <br />
                <em>más clara, cada día.</em>
              </h1>
              <p>
                Información ordenada para acompañar cada paso de la formación
                técnica.
              </p>
            </div>
            <span className="login-side-footer">
              CETPRO “Joaquín López Antay” · Ayacucho, Perú
            </span>
          </div>
          <div className="login-decoration decoration-one" />
          <div className="login-decoration decoration-two" />
        </div>
        <main className="login-main">
          <div className="login-mobile-logo">
            <Logo />
          </div>
          <div className="login-card">
            <div className="login-icon">
              <Icon name="shield" size={24} />
            </div>
            <div className="eyebrow">ACCESO AL SISTEMA</div>
            <h2>Bienvenido de nuevo</h2>
            <p className="login-subtitle">
              Ingresa tus credenciales para continuar.
            </p>
            <form onSubmit={login} className="login-form">
              <Field label="Usuario">
                <input
                  autoComplete="username"
                  placeholder="Ingresa tu usuario"
                  value={loginUser}
                  onChange={(e) => {
                    setLoginUser(e.target.value)
                    setLoginError(false)
                  }}
                  required
                />
              </Field>
              <Field label="Contraseña">
                <input
                  type="password"
                  autoComplete="current-password"
                  placeholder="Ingresa tu contraseña"
                  value={loginPassword}
                  onChange={(e) => {
                    setLoginPassword(e.target.value)
                    setLoginError(false)
                  }}
                  required
                />
              </Field>
              {loginError && (
                <div className="error-box" role="alert">
                  Usuario o contraseña incorrectos. Verifica tus datos e intenta
                  de nuevo.
                </div>
              )}
              <button className="btn btn-primary login-submit" type="submit">
                Ingresar <Icon name="arrow" size={18} />
              </button>
            </form>
            <div className="demo-credentials">
              <strong>Acceso de demostración</strong>
              <span>
                Matrícula: <b>matricula</b> · Directivo: <b>directivo</b> ·
                Admin: <b>admin</b>
              </span>
              <span>
                Contraseña: <b>CJLA2026</b>
              </span>
            </div>
          </div>
          <div className="login-main-footer">
            © 2026 CETPRO Joaquín López Antay{" "}
            <span>Uso interno institucional</span>
          </div>
        </main>
      </div>
    )

  const menu: { key: Page; label: string; icon: IconName }[] =
    role === "directivo"
      ? [{ key: "reportes", label: "Reportes", icon: "chart" }]
      : [
          { key: "dashboard", label: "Dashboard", icon: "grid" },
          { key: "matriculas", label: "Matrícula", icon: "file" },
          { key: "especialidades", label: "Especialidades", icon: "layers" },
          { key: "reportes", label: "Reportes", icon: "chart" },
          { key: "administracion", label: "Administración", icon: "settings" },
        ]
  const activeMenu =
    page === "nueva" || page === "detalle" ? "matriculas" : page
  return (
    <div className="app-shell">
      {mobileOpen && (
        <div className="sidebar-scrim" onClick={() => setMobileOpen(false)} />
      )}
      <aside className={`sidebar ${mobileOpen ? "sidebar-open" : ""}`}>
        <div className="sidebar-brand">
          <Logo light />
          <button
            className="mobile-close icon-button"
            onClick={() => setMobileOpen(false)}
            aria-label="Cerrar menú"
          >
            <Icon name="close" />
          </button>
        </div>
        <div className="sidebar-body">
          <span className="sidebar-caption">MENÚ PRINCIPAL</span>
          <nav aria-label="Navegación principal">
            {menu.map((item) => (
              <button
                key={item.key}
                className={`nav-item ${
                  activeMenu === item.key ? "active" : ""
                }`}
                onClick={() => navigate(item.key)}
              >
                <Icon name={item.icon} size={19} />
                <span>{item.label}</span>
                {activeMenu === item.key && (
                  <span className="nav-active-marker" />
                )}
              </button>
            ))}
          </nav>
        </div>
        <div className="sidebar-bottom">
          <div className="sidebar-help">
            <div className="sidebar-help-icon">
              <Icon name="shield" size={19} />
            </div>
            <strong>Gestión segura</strong>
            <p>Tu espacio de trabajo institucional.</p>
          </div>
          <button
            className="sidebar-user"
            onClick={logout}
            title="Cerrar sesión"
          >
            <span className="avatar">
              {currentUser?.name
                .split(" ")
                .map((word) => word[0])
                .slice(0, 2)
                .join("") || "CJ"}
            </span>
            <span className="sidebar-user-text">
              <strong>{currentUser?.name || "Usuario"}</strong>
              <small>{currentUser?.role || "Usuario"}</small>
            </span>
            <Icon name="logout" size={17} />
          </button>
        </div>
      </aside>
      <div className="workspace">
        <header className="topbar">
          <div className="topbar-left">
            <button
              className="mobile-menu icon-button"
              onClick={() => setMobileOpen(true)}
              aria-label="Abrir menú"
            >
              <Icon name="menu" />
            </button>
            <span className="topbar-location">Sistema de Matrícula</span>
            <Icon name="chevron" size={14} className="topbar-chevron" />
            <span className="topbar-current">
              {page === "nueva"
                ? editingCode
                  ? "Editar matrícula"
                  : "Nueva matrícula"
                : page === "detalle"
                  ? "Detalle de matrícula"
                  : menu.find((m) => m.key === page)?.label}
            </span>
          </div>
          <div className="topbar-right">
            <span className="topbar-period">
              <Icon name="calendar" size={16} /> Periodo 2026-I
            </span>
            <span className="topbar-divider" />
            <span className="topbar-avatar">
              {currentUser?.name
                .split(" ")
                .map((word) => word[0])
                .slice(0, 2)
                .join("") || "CJ"}
            </span>
          </div>
        </header>
        <main className="content">
          {page === "dashboard" && (
            <>
              <div className="heading-row">
                <SectionHeading
                  kicker="VISTA GENERAL / PERIODO 2026-I"
                  title="Dashboard"
                  description="Un panorama de la actividad académica de tu institución."
                />
                <button className="btn btn-primary" onClick={startNew}>
                  <Icon name="plus" size={18} /> Nueva matrícula
                </button>
              </div>
              <div className="welcome-strip">
                <div>
                  <span className="welcome-label">RESUMEN ACADÉMICO</span>
                  <h2>Todo en orden, {currentUser?.name.split(" ")[0]}.</h2>
                  <p>
                    Consulta las matrículas y mantén al día la información de
                    tus estudiantes.
                  </p>
                </div>
                <div className="welcome-graphic">
                  <span>2026</span>
                  <div className="graphic-line line-a" />
                  <div className="graphic-line line-b" />
                  <div className="graphic-line line-c" />
                </div>
              </div>
              <div className="stats-grid">
                <div className="stat-card">
                  <div className="stat-top">
                    <span>Matriculados</span>
                    <span className="stat-icon blue">
                      <Icon name="users" size={21} />
                    </span>
                  </div>
                  <div className="stat-value">
                    {data.filter((e) => e.status === "Vigente").length + 1239}
                  </div>
                  <div className="stat-foot">
                    <span className="positive">● Activos</span>
                    <span>en el periodo actual</span>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-top">
                    <span>Especialidades activas</span>
                    <span className="stat-icon teal">
                      <Icon name="layers" size={21} />
                    </span>
                  </div>
                  <div className="stat-value">
                    {specialtyNames.length.toString().padStart(2, "0")}
                  </div>
                  <div className="stat-foot">
                    <span>Oferta formativa vigente</span>
                  </div>
                </div>
                <div className="stat-card">
                  <div className="stat-top">
                    <span>Matrículas hoy</span>
                    <span className="stat-icon amber">
                      <Icon name="calendar" size={21} />
                    </span>
                  </div>
                  <div className="stat-value">
                    {data.filter(
                      (e) => e.date === new Date().toISOString().slice(0, 10),
                    ).length + 18}
                  </div>
                  <div className="stat-foot">
                    <span>Registros realizados hoy</span>
                  </div>
                </div>
              </div>
              <div className="panel table-panel">
                <div className="panel-header">
                  <div>
                    <h2>Últimas matrículas</h2>
                    <p>Los registros más recientes del periodo en curso</p>
                  </div>
                  <button
                    className="text-link"
                    onClick={() => navigate("matriculas")}
                  >
                    Ver todas <Icon name="arrow" size={16} />
                  </button>
                </div>
                <div className="table-scroll">
                  <table>
                    <thead>
                      <tr>
                        <th>CÓDIGO</th>
                        <th>ESTUDIANTE</th>
                        <th>DNI</th>
                        <th>ESPECIALIDAD</th>
                        <th>TURNO</th>
                        <th>ESTADO</th>
                      </tr>
                    </thead>
                    <tbody>
                      {data.slice(0, 5).map((e) => (
                        <tr
                          key={e.code}
                          onClick={() => view(e)}
                          className="clickable-row"
                        >
                          <td className="code-cell">{e.code}</td>
                          <td className="name-cell">{fullName(e)}</td>
                          <td>{e.dni}</td>
                          <td>{e.specialty}</td>
                          <td>{e.shift}</td>
                          <td>
                            <Badge status={e.status} />
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="panel-footer">
                  <span>Mostrando las 5 matrículas más recientes</span>
                  <span>Periodo académico 2026-I</span>
                </div>
              </div>
            </>
          )}
          {page === "matriculas" && (
            <>
              <div className="heading-row">
                <SectionHeading
                  kicker="GESTIÓN ACADÉMICA / MATRÍCULA"
                  title="Matrículas"
                  description="Consulta y administra los registros de estudiantes."
                />
                <button className="btn btn-primary" onClick={startNew}>
                  <Icon name="plus" size={18} /> Nueva matrícula
                </button>
              </div>
              <div className="panel table-panel">
                <div className="panel-header">
                  <div>
                    <h2>Registro de matrículas</h2>
                    <p>
                      {filtered.length} registros encontrados en el periodo
                      2026-I
                    </p>
                  </div>
                  <span className="panel-tag">
                    <Icon name="filter" size={15} /> Filtros
                  </span>
                </div>
                <div className="filters">
                  <div className="search-box">
                    <Icon name="search" size={18} />
                    <input
                      aria-label="Buscar por código, DNI o nombre"
                      placeholder="Buscar por código, DNI o nombre..."
                      value={query}
                      onChange={(e) => setQuery(e.target.value)}
                    />
                  </div>
                  <select
                    aria-label="Filtrar por especialidad"
                    value={filterSpecialty}
                    onChange={(e) => setFilterSpecialty(e.target.value)}
                  >
                    <option value="">Todas las especialidades</option>
                    {specialtyNames.map((s) => (
                      <option key={s}>{s}</option>
                    ))}
                  </select>
                  <select
                    aria-label="Filtrar por turno"
                    value={filterShift}
                    onChange={(e) => setFilterShift(e.target.value)}
                  >
                    <option value="">Todos los turnos</option>
                    {shifts.map((s) => (
                      <option key={s}>{s}</option>
                    ))}
                  </select>
                  <select
                    aria-label="Filtrar por estado"
                    value={filterStatus}
                    onChange={(e) => setFilterStatus(e.target.value)}
                  >
                    <option value="">Todos los estados</option>
                    {(["Vigente", "Retirada", "Anulada"] as Status[]).map(
                      (s) => (
                        <option key={s}>{s}</option>
                      ),
                    )}
                  </select>
                </div>
                <div className="table-scroll">
                  <table>
                    <thead>
                      <tr>
                        <th>CÓDIGO</th>
                        <th>DNI</th>
                        <th>ESTUDIANTE</th>
                        <th>ESPECIALIDAD</th>
                        <th>TURNO</th>
                        <th>ESTADO</th>
                        <th>FECHA</th>
                        <th className="actions-head">ACCIONES</th>
                      </tr>
                    </thead>
                    <tbody>
                      {shown.map((e) => (
                        <tr key={e.code}>
                          <td className="code-cell">{e.code}</td>
                          <td>{e.dni}</td>
                          <td className="name-cell">{fullName(e)}</td>
                          <td>{e.specialty}</td>
                          <td>{e.shift}</td>
                          <td>
                            <Badge status={e.status} />
                          </td>
                          <td>{dateDisplay(e.date)}</td>
                          <td>
                            <div className="row-actions">
                              <button
                                title="Ver detalle"
                                aria-label={`Ver ${e.code}`}
                                onClick={() => view(e)}
                              >
                                <Icon name="eye" size={16} />
                              </button>
                              <button
                                title="Editar"
                                aria-label={`Editar ${e.code}`}
                                onClick={() => edit(e)}
                              >
                                <Icon name="edit" size={16} />
                              </button>
                              <button
                                title="Anular"
                                aria-label={`Anular ${e.code}`}
                                disabled={e.status === "Anulada"}
                                onClick={() => annul(e)}
                              >
                                <Icon name="ban" size={16} />
                              </button>
                              <button
                                title="Emitir constancia PDF"
                                aria-label={`Emitir constancia ${e.code}`}
                                disabled={e.status === "Anulada"}
                                onClick={() => print("constancia", e.code)}
                              >
                                <Icon name="download" size={16} />
                              </button>
                            </div>
                          </td>
                        </tr>
                      ))}
                      {shown.length === 0 && (
                        <tr>
                          <td colSpan={8} className="empty-table">
                            No se encontraron matrículas con estos filtros.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
                <div className="panel-footer">
                  <span>
                    Mostrando{" "}
                    {filtered.length
                      ? (Math.min(listPage, pages) - 1) * 5 + 1
                      : 0}
                    –{Math.min(Math.min(listPage, pages) * 5, filtered.length)}{" "}
                    de {filtered.length} registros
                  </span>
                  <div className="pagination">
                    <button
                      disabled={listPage === 1}
                      onClick={() => setListPage((p) => p - 1)}
                      aria-label="Página anterior"
                    >
                      <Icon name="chevron" className="rotate-180" size={16} />
                    </button>
                    {Array.from({ length: pages }, (_, i) => (
                      <button
                        key={i}
                        className={listPage === i + 1 ? "current" : ""}
                        onClick={() => setListPage(i + 1)}
                      >
                        {i + 1}
                      </button>
                    ))}
                    <button
                      disabled={listPage >= pages}
                      onClick={() => setListPage((p) => p + 1)}
                      aria-label="Página siguiente"
                    >
                      <Icon name="chevron" size={16} />
                    </button>
                  </div>
                </div>
              </div>
            </>
          )}
          {page === "nueva" && (
            <>
              <div className="breadcrumb-back">
                <button onClick={() => navigate("matriculas")}>
                  <Icon name="chevron" className="rotate-180" size={16} />{" "}
                  Volver a matrículas
                </button>
              </div>
              <SectionHeading
                kicker="GESTIÓN ACADÉMICA / MATRÍCULA"
                title={editingCode ? "Editar matrícula" : "Nueva matrícula"}
                description={
                  editingCode
                    ? `Actualiza los datos del registro ${editingCode}.`
                    : "Completa la información para registrar a un nuevo estudiante."
                }
              />
              {confirmed ? (
                <div className="success-panel">
                  <div className="success-icon">
                    <Icon name="check" size={30} />
                  </div>
                  <div className="eyebrow">REGISTRO COMPLETADO</div>
                  <h2>¡Matrícula guardada con éxito!</h2>
                  <p>
                    La información del estudiante quedó registrada
                    correctamente.
                  </p>
                  <div className="success-code">
                    <span>Código de matrícula</span>
                    <strong>{confirmed}</strong>
                  </div>
                  <div className="success-actions">
                    <button
                      className="btn btn-primary"
                      onClick={() => print("constancia", confirmed)}
                    >
                      <Icon name="download" size={17} /> Emitir constancia PDF
                    </button>
                    <button
                      className="btn btn-outline"
                      onClick={() => navigate("matriculas")}
                    >
                      Ver matrículas
                    </button>
                    <button className="btn btn-quiet" onClick={startNew}>
                      Registrar otra matrícula
                    </button>
                  </div>
                </div>
              ) : (
                <form className="enrollment-form" onSubmit={submitEnrollment}>
                  <div className="form-progress">
                    <span className="progress-item">
                      <b>01</b> Estudiante
                    </span>
                    <span className="progress-line" />
                    <span className="progress-item">
                      <b>02</b> Académico
                    </span>
                    <span className="progress-line" />
                    <span className="progress-item">
                      <b>03</b> Pago
                    </span>
                  </div>
                  <div className="form-section panel">
                    <div className="form-section-heading">
                      <span className="section-number">01</span>
                      <div>
                        <h2>Datos del estudiante</h2>
                        <p>
                          Información personal y de contacto del estudiante.
                        </p>
                      </div>
                    </div>
                    <div className="form-grid">
                      <Field label="Nombres" required>
                        <input
                          value={form.first}
                          onChange={(e) => update("first", e.target.value)}
                          placeholder="Ej. María Fernanda"
                          required
                        />
                      </Field>
                      <Field label="Apellidos" required>
                        <input
                          value={form.last}
                          onChange={(e) => update("last", e.target.value)}
                          placeholder="Ej. Quispe Huamán"
                          required
                        />
                      </Field>
                      <Field label="DNI" required>
                        <input
                          value={form.dni}
                          onChange={(e) =>
                            update(
                              "dni",
                              e.target.value.replace(/\D/g, "").slice(0, 8),
                            )
                          }
                          inputMode="numeric"
                          placeholder="8 dígitos"
                          maxLength={8}
                          required
                        />
                      </Field>
                      <Field label="Fecha de nacimiento" required>
                        <input
                          type="date"
                          value={form.birth}
                          onChange={(e) => update("birth", e.target.value)}
                          required
                        />
                      </Field>
                      <Field label="Dirección" required>
                        <input
                          value={form.address}
                          onChange={(e) => update("address", e.target.value)}
                          placeholder="Dirección de residencia"
                          required
                        />
                      </Field>
                      <Field label="Correo electrónico">
                        <input
                          type="email"
                          value={form.email}
                          onChange={(e) => update("email", e.target.value)}
                          placeholder="correo@ejemplo.com"
                        />
                      </Field>
                      <Field label="Celular" required>
                        <input
                          value={form.phone}
                          onChange={(e) =>
                            update(
                              "phone",
                              e.target.value.replace(/\D/g, "").slice(0, 9),
                            )
                          }
                          inputMode="numeric"
                          placeholder="9 dígitos"
                          pattern="[0-9]{9}"
                          required
                        />
                      </Field>
                    </div>
                  </div>
                  <div className="form-section panel">
                    <div className="form-section-heading">
                      <span className="section-number">02</span>
                      <div>
                        <h2>Información académica</h2>
                        <p>Define el programa y las condiciones de ingreso.</p>
                      </div>
                    </div>
                    <div className="form-grid">
                      <Field label="Especialidad" required>
                        <select
                          value={form.specialty}
                          onChange={(e) => update("specialty", e.target.value)}
                          required
                        >
                          <option value="">Selecciona una especialidad</option>
                          {specialtyNames.map((s) => (
                            <option key={s}>{s}</option>
                          ))}
                        </select>
                      </Field>
                      <Field label="Periodo académico" required>
                        <select
                          value={form.period}
                          onChange={(e) => update("period", e.target.value)}
                          required
                        >
                          <option>2026-I</option>
                          <option>2026-II</option>
                        </select>
                      </Field>
                      <Field label="Turno" required>
                        <select
                          value={form.shift}
                          onChange={(e) => update("shift", e.target.value)}
                          required
                        >
                          <option value="">Selecciona un turno</option>
                          {shifts.map((s) => (
                            <option key={s}>{s}</option>
                          ))}
                        </select>
                      </Field>
                      <Field label="Tipo de ingreso" required>
                        <select
                          value={form.entry}
                          onChange={(e) => update("entry", e.target.value)}
                          required
                        >
                          {[
                            "Nuevo",
                            "Reingresante",
                            "Trasladado",
                            "Retirado antes",
                          ].map((s) => (
                            <option key={s}>{s}</option>
                          ))}
                        </select>
                      </Field>
                      {form.entry !== "Nuevo" && (
                        <div className="field-full">
                          <Field
                            label="Especialidad o institución de origen"
                            required
                          >
                            <input
                              value={form.origin}
                              onChange={(e) => update("origin", e.target.value)}
                              placeholder="Indica la especialidad o institución anterior"
                              required
                            />
                          </Field>
                        </div>
                      )}
                    </div>
                  </div>
                  <div className="form-section panel">
                    <div className="form-section-heading">
                      <span className="section-number">03</span>
                      <div>
                        <h2>Pago y beneficios</h2>
                        <p>
                          Registra el monto y cualquier beneficio aplicable.
                        </p>
                      </div>
                    </div>
                    <div className="form-grid">
                      <Field label="Monto de matrícula (S/)" required>
                        <input
                          type="number"
                          min="0"
                          step="0.01"
                          value={form.amount}
                          onChange={(e) => update("amount", e.target.value)}
                          required
                        />
                      </Field>
                      <div className="field checkbox-field">
                        <span className="field-label">Beneficios</span>
                        <label className="checkbox-label">
                          <input
                            type="checkbox"
                            checked={form.scholarship}
                            onChange={(e) =>
                              update("scholarship", e.target.checked)
                            }
                          />
                          <span>Aplicar beca o exoneración</span>
                        </label>
                      </div>
                      {form.scholarship && (
                        <>
                          <Field label="Convenio" required>
                            <select
                              value={form.agreement}
                              onChange={(e) =>
                                update("agreement", e.target.value)
                              }
                              required
                            >
                              <option value="">Selecciona un convenio</option>
                              {agreements
                                .filter((a) => a.status === "Activo")
                                .map((a) => (
                                  <option key={a.name}>{a.name}</option>
                                ))}
                            </select>
                          </Field>
                          <Field
                            label="Porcentaje de descuento"
                            required
                            hint={`Máximo de este convenio: ${agreements.find((a) => a.name === form.agreement)?.percent || 50}%`}
                          >
                            <div className="input-suffix">
                              <input
                                type="number"
                                min="1"
                                max={
                                  agreements.find(
                                    (a) => a.name === form.agreement,
                                  )?.percent || 50
                                }
                                value={form.percentage}
                                onChange={(e) => {
                                  update("percentage", e.target.value)
                                  if (
                                    Number(e.target.value) >
                                    (agreements.find(
                                      (a) => a.name === form.agreement,
                                    )?.percent || 50)
                                  )
                                    setFormError(
                                      "El descuento supera el porcentaje máximo de este convenio.",
                                    )
                                }}
                                placeholder="Ej. 25"
                                required
                              />
                              <span>%</span>
                            </div>
                          </Field>
                        </>
                      )}
                    </div>
                  </div>
                  {formError && (
                    <div className="error-box" role="alert">
                      {formError}
                    </div>
                  )}
                  <div className="form-actions">
                    <button
                      type="button"
                      className="btn btn-outline"
                      onClick={() => navigate("matriculas")}
                    >
                      Cancelar
                    </button>
                    <button type="submit" className="btn btn-primary">
                      <Icon name="check" size={18} />
                      {editingCode ? "Guardar cambios" : "Registrar matrícula"}
                    </button>
                  </div>
                </form>
              )}
            </>
          )}
          {page === "detalle" && selected && (
            <>
              <div className="breadcrumb-back">
                <button onClick={() => navigate("matriculas")}>
                  <Icon name="chevron" className="rotate-180" size={16} />{" "}
                  Volver a matrículas
                </button>
              </div>
              <div className="heading-row">
                <SectionHeading
                  kicker="GESTIÓN ACADÉMICA / DETALLE"
                  title="Detalle de matrícula"
                  description={`Registro ${selected.code} · ${dateDisplay(selected.date)}`}
                />
                <div className="heading-actions">
                  <button
                    className="btn btn-outline"
                    onClick={() => edit(selected)}
                  >
                    <Icon name="edit" size={17} /> Editar
                  </button>
                  <button
                    className="btn btn-primary"
                    disabled={selected.status === "Anulada"}
                    onClick={() => print("constancia", selected.code)}
                  >
                    <Icon name="download" size={17} /> Emitir constancia PDF
                  </button>
                </div>
              </div>
              <div className="detail-banner panel">
                <div>
                  <span className="eyebrow">CÓDIGO DE MATRÍCULA</span>
                  <h2>{selected.code}</h2>
                  <p>
                    {fullName(selected)} · DNI {selected.dni}
                  </p>
                </div>
                <Badge status={selected.status} />
              </div>
              <div className="detail-grid">
                <div className="panel detail-card">
                  <h3>Datos del estudiante</h3>
                  <dl>
                    <div>
                      <dt>Nombres y apellidos</dt>
                      <dd>{fullName(selected)}</dd>
                    </div>
                    <div>
                      <dt>DNI</dt>
                      <dd>{selected.dni}</dd>
                    </div>
                    <div>
                      <dt>Fecha de nacimiento</dt>
                      <dd>{dateDisplay(selected.birth)}</dd>
                    </div>
                    <div>
                      <dt>Dirección</dt>
                      <dd>{selected.address}</dd>
                    </div>
                    <div>
                      <dt>Correo electrónico</dt>
                      <dd>{selected.email || "—"}</dd>
                    </div>
                    <div>
                      <dt>Celular</dt>
                      <dd>{selected.phone}</dd>
                    </div>
                  </dl>
                </div>
                <div className="panel detail-card">
                  <h3>Información académica y pago</h3>
                  <dl>
                    <div>
                      <dt>Especialidad</dt>
                      <dd>{selected.specialty}</dd>
                    </div>
                    <div>
                      <dt>Periodo / turno</dt>
                      <dd>
                        {selected.period} · {selected.shift}
                      </dd>
                    </div>
                    <div>
                      <dt>Tipo de ingreso</dt>
                      <dd>{selected.entry}</dd>
                    </div>
                    {selected.origin && (
                      <div>
                        <dt>Origen</dt>
                        <dd>{selected.origin}</dd>
                      </div>
                    )}
                    <div>
                      <dt>Monto</dt>
                      <dd>S/ {Number(selected.amount).toFixed(2)}</dd>
                    </div>
                    <div>
                      <dt>Beca / exoneración</dt>
                      <dd>
                        {selected.scholarship
                          ? `${selected.agreement} · ${selected.percentage}%`
                          : "No aplica"}
                      </dd>
                    </div>
                  </dl>
                </div>
              </div>
            </>
          )}
          {page === "especialidades" && (
            <SpecialtiesPage
              catalog={catalog}
              setCatalog={setCatalog}
              offers={offers}
              setOffers={setOffers}
            />
          )}
          {page === "reportes" && (
            <ReportsPage
              data={data}
              specialtyNames={specialtyNames}
              documents={documents}
              onPrint={print}
              onExcel={exportExcel}
            />
          )}
          {page === "administracion" && (
            <AdministrationPage
              users={users}
              setUsers={setUsers}
              agreements={agreements}
              setAgreements={setAgreements}
            />
          )}
        </main>
        <footer className="workspace-footer">
          <span>© 2026 CETPRO Joaquín López Antay</span>
          <span>Sistema de Matrícula · Uso interno</span>
        </footer>
      </div>
    </div>
  )
}

function Tabs({
  items,
  active,
  onChange,
}: {
  items: string[]
  active: string
  onChange: (tab: string) => void
}) {
  return (
    <div className="management-tabs" role="tablist" aria-label="Secciones">
      {items.map((item) => (
        <button
          key={item}
          type="button"
          role="tab"
          aria-selected={active === item}
          className={active === item ? "selected" : ""}
          onClick={() => onChange(item)}
        >
          {item}
        </button>
      ))}
    </div>
  )
}

function SpecialtyStatus({ active }: { active: boolean }) {
  return (
    <span className={`badge ${active ? "badge-vigente" : "badge-anulada"}`}>
      <span className="badge-dot" />
      {active ? "Activa" : "Inactiva"}
    </span>
  )
}

function SpecialtiesPage({
  catalog,
  setCatalog,
  offers,
  setOffers,
}: {
  catalog: Specialty[]
  setCatalog: React.Dispatch<React.SetStateAction<Specialty[]>>
  offers: Offer[]
  setOffers: React.Dispatch<React.SetStateAction<Offer[]>>
}) {
  const [tab, setTab] = useState("Catálogo")
  const [adding, setAdding] = useState(false)
  const [error, setError] = useState("")
  const [specialty, setSpecialty] = useState<Specialty>({
    name: "",
    modality: "Título Técnico · 2 años",
    family: "",
    active: true,
  })
  const [offer, setOffer] = useState<Offer>({
    specialty: "",
    period: "2026-I",
    shift: "Mañana",
    teacher: "",
    capacity: 30,
    enrolled: 0,
  })
  const available = catalog.filter((s) => s.active)
  function changeTab(next: string) {
    setTab(next)
    setAdding(false)
    setError("")
  }
  function saveSpecialty(e: React.FormEvent) {
    e.preventDefault()
    if (
      catalog.some(
        (s) => s.name.toLowerCase() === specialty.name.trim().toLowerCase(),
      )
    ) {
      setError("Ya existe una especialidad con ese nombre.")
      return
    }
    setCatalog((prev) => [
      ...prev,
      {
        ...specialty,
        name: specialty.name.trim(),
        family: specialty.family.trim(),
      },
    ])
    setSpecialty({
      name: "",
      modality: "Título Técnico · 2 años",
      family: "",
      active: true,
    })
    setAdding(false)
    setError("")
  }
  function saveOffer(e: React.FormEvent) {
    e.preventDefault()
    if (
      offers.some(
        (o) =>
          o.specialty === offer.specialty &&
          o.period === offer.period &&
          o.shift === offer.shift,
      )
    ) {
      setError("Ya existe una oferta para esta especialidad, periodo y turno.")
      return
    }
    setOffers((prev) => [...prev, { ...offer, teacher: offer.teacher.trim() }])
    setOffer({
      specialty: "",
      period: "2026-I",
      shift: "Mañana",
      teacher: "",
      capacity: 30,
      enrolled: 0,
    })
    setAdding(false)
    setError("")
  }
  return (
    <>
      <SectionHeading
        kicker="OFERTA FORMATIVA / PERIODO 2026-I"
        title="Especialidades"
        description="Administra el catálogo institucional y las ofertas disponibles por periodo."
      />
      <div className="management-summary">
        <span className="management-summary-icon">
          <Icon name="layers" size={22} />
        </span>
        <div>
          <strong>Oferta formativa institucional</strong>
          <p>
            {catalog.filter((s) => s.active).length} especialidades activas ·{" "}
            {offers.length} ofertas registradas para estudiantes
          </p>
        </div>
        <span className="summary-period">PERIODO 2026-I</span>
      </div>
      <div className="management-tab-row">
        <Tabs
          items={["Catálogo", "Ofertas por periodo"]}
          active={tab}
          onChange={changeTab}
        />
        <button
          className="btn btn-primary"
          onClick={() => {
            setAdding(true)
            setError("")
          }}
        >
          <Icon name="plus" size={17} />
          {tab === "Catálogo" ? "Nueva especialidad" : "Nueva oferta"}
        </button>
      </div>
      {adding && (
        <form
          className="panel management-form"
          onSubmit={tab === "Catálogo" ? saveSpecialty : saveOffer}
        >
          <div className="management-form-head">
            <div>
              <span className="eyebrow">NUEVO REGISTRO</span>
              <h2>
                {tab === "Catálogo"
                  ? "Nueva especialidad"
                  : "Nueva oferta por periodo"}
              </h2>
            </div>
            <button
              type="button"
              className="icon-button"
              aria-label="Cerrar formulario"
              onClick={() => setAdding(false)}
            >
              <Icon name="close" />
            </button>
          </div>
          <div className="form-grid">
            {tab === "Catálogo" ? (
              <>
                <Field label="Nombre de la especialidad" required>
                  <input
                    value={specialty.name}
                    onChange={(e) =>
                      setSpecialty({ ...specialty, name: e.target.value })
                    }
                    placeholder="Ej. Carpintería"
                    required
                  />
                </Field>
                <Field label="Modalidad" required>
                  <select
                    value={specialty.modality}
                    onChange={(e) =>
                      setSpecialty({ ...specialty, modality: e.target.value })
                    }
                  >
                    <option>Título Técnico · 2 años</option>
                    <option>Auxiliar Técnico · 1 año</option>
                  </select>
                </Field>
                <Field label="Familia profesional" required>
                  <input
                    value={specialty.family}
                    onChange={(e) =>
                      setSpecialty({ ...specialty, family: e.target.value })
                    }
                    placeholder="Ej. Industrias manufactureras"
                    required
                  />
                </Field>
                <Field label="Estado">
                  <select
                    value={specialty.active ? "Activa" : "Inactiva"}
                    onChange={(e) =>
                      setSpecialty({
                        ...specialty,
                        active: e.target.value === "Activa",
                      })
                    }
                  >
                    <option>Activa</option>
                    <option>Inactiva</option>
                  </select>
                </Field>
              </>
            ) : (
              <>
                <Field label="Especialidad" required>
                  <select
                    value={offer.specialty}
                    onChange={(e) =>
                      setOffer({ ...offer, specialty: e.target.value })
                    }
                    required
                  >
                    <option value="">Selecciona una especialidad</option>
                    {available.map((s) => (
                      <option key={s.name}>{s.name}</option>
                    ))}
                  </select>
                </Field>
                <Field label="Periodo" required>
                  <select
                    value={offer.period}
                    onChange={(e) =>
                      setOffer({ ...offer, period: e.target.value })
                    }
                  >
                    <option>2026-I</option>
                    <option>2026-II</option>
                  </select>
                </Field>
                <Field label="Turno" required>
                  <select
                    value={offer.shift}
                    onChange={(e) =>
                      setOffer({ ...offer, shift: e.target.value })
                    }
                  >
                    {shifts.map((s) => (
                      <option key={s}>{s}</option>
                    ))}
                  </select>
                </Field>
                <Field label="Docente" required>
                  <input
                    value={offer.teacher}
                    onChange={(e) =>
                      setOffer({ ...offer, teacher: e.target.value })
                    }
                    placeholder="Nombre completo"
                    required
                  />
                </Field>
                <Field label="Cupo referencial" required>
                  <input
                    type="number"
                    min="1"
                    value={offer.capacity}
                    onChange={(e) =>
                      setOffer({ ...offer, capacity: Number(e.target.value) })
                    }
                    required
                  />
                </Field>
              </>
            )}
          </div>
          {error && (
            <div className="error-box" role="alert">
              {error}
            </div>
          )}
          <div className="management-form-actions">
            <button
              type="button"
              className="btn btn-outline"
              onClick={() => setAdding(false)}
            >
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary">
              Guardar {tab === "Catálogo" ? "especialidad" : "oferta"}
            </button>
          </div>
        </form>
      )}
      <div className="panel table-panel">
        <div className="panel-header">
          <div>
            <h2>
              {tab === "Catálogo"
                ? "Catálogo de especialidades"
                : "Ofertas por periodo"}
            </h2>
            <p>
              {tab === "Catálogo"
                ? "Programas de formación técnica registrados en la institución"
                : "Programación vigente de turnos, docentes y cupos"}
            </p>
          </div>
          <span className="table-count">
            {tab === "Catálogo" ? catalog.length : offers.length} registros
          </span>
        </div>
        <div className="table-scroll">
          {tab === "Catálogo" ? (
            <table>
              <thead>
                <tr>
                  <th>NOMBRE</th>
                  <th>MODALIDAD</th>
                  <th>FAMILIA PROFESIONAL</th>
                  <th>ESTADO</th>
                  <th>ACCIÓN</th>
                </tr>
              </thead>
              <tbody>
                {catalog.map((s, i) => (
                  <tr key={s.name}>
                    <td className="name-cell">
                      <div className="specialty-name">
                        <span className="specialty-icon">
                          <Icon name="layers" size={17} />
                        </span>
                        {s.name}
                      </div>
                    </td>
                    <td>{s.modality}</td>
                    <td>{s.family}</td>
                    <td>
                      <SpecialtyStatus active={s.active} />
                    </td>
                    <td>
                      <button
                        className="mini-action"
                        onClick={() =>
                          setCatalog((prev) =>
                            prev.map((item, index) =>
                              index === i
                                ? { ...item, active: !item.active }
                                : item,
                            ),
                          )
                        }
                      >
                        {s.active ? "Desactivar" : "Activar"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>ESPECIALIDAD</th>
                  <th>PERIODO</th>
                  <th>TURNO</th>
                  <th>DOCENTE</th>
                  <th>CUPO REFERENCIAL</th>
                  <th>MATRICULADOS ACTUALES</th>
                </tr>
              </thead>
              <tbody>
                {offers.map((o, i) => (
                  <tr key={`${o.specialty}-${o.period}-${o.shift}-${i}`}>
                    <td className="name-cell">{o.specialty}</td>
                    <td className="code-cell">{o.period}</td>
                    <td>{o.shift}</td>
                    <td>{o.teacher}</td>
                    <td>~{o.capacity} vacantes</td>
                    <td>
                      <div className="capacity">
                        <strong>
                          {o.enrolled} de ~{o.capacity}
                        </strong>
                        <div className="capacity-bar">
                          <i
                            style={{
                              width: `${Math.min(100, (o.enrolled / o.capacity) * 100)}%`,
                            }}
                          />
                        </div>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
        <div className="panel-footer">
          <span>
            {tab === "Catálogo"
              ? "Las especialidades inactivas no aparecen al crear ofertas."
              : "Los cupos son referenciales y pueden variar según disponibilidad."}
          </span>
          <span>Actualizado para 2026-I</span>
        </div>
      </div>
    </>
  )
}

function ReportsPage({
  data,
  specialtyNames,
  documents,
  onPrint,
  onExcel,
}: {
  data: Enrollment[]
  specialtyNames: string[]
  documents: DocumentRecord[]
  onPrint: (
    kind: "constancia" | "nomina",
    code?: string,
    rows?: Enrollment[],
    record?: boolean,
  ) => void
  onExcel: (rows: Enrollment[], record?: boolean) => void
}) {
  const [selected, setSelected] = useState<"constancia" | "nomina">(
    "constancia",
  )
  const [search, setSearch] = useState("")
  const [specialty, setSpecialty] = useState("")
  const [shift, setShift] = useState("")
  const [period, setPeriod] = useState("2026-I")
  const matches = search.trim()
    ? data.filter(
        (e) =>
          e.status === "Vigente" &&
          (e.dni.includes(search.trim()) ||
            e.code.toLowerCase().includes(search.trim().toLowerCase()) ||
            fullName(e).toLowerCase().includes(search.trim().toLowerCase())),
      )
    : []
  const rows = data.filter(
    (e) =>
      e.status === "Vigente" &&
      (!specialty || e.specialty === specialty) &&
      (!shift || e.shift === shift) &&
      e.period === period,
  )
  function download(doc: DocumentRecord) {
    if (doc.format === "Excel") onExcel(doc.rows || [], false)
    else onPrint(doc.code ? "constancia" : "nomina", doc.code, doc.rows, false)
  }
  return (
    <>
      <SectionHeading
        kicker="ANÁLISIS Y DOCUMENTOS / PERIODO 2026-I"
        title="Reportes"
        description="Emite documentación oficial y consulta los documentos generados."
      />
      <div className="report-select-grid">
        <button
          className={`report-select-card ${
            selected === "constancia" ? "selected" : ""
          }`}
          onClick={() => setSelected("constancia")}
        >
          <span className="report-icon blue">
            <Icon name="file" size={23} />
          </span>
          <span>
            <small>DOCUMENTO INDIVIDUAL</small>
            <strong>Constancia de matrícula</strong>
            <em>Emite el comprobante de un estudiante vigente.</em>
          </span>
          <Icon name="chevron" size={19} className="report-select-arrow" />
        </button>
        <button
          className={`report-select-card ${
            selected === "nomina" ? "selected" : ""
          }`}
          onClick={() => setSelected("nomina")}
        >
          <span className="report-icon teal">
            <Icon name="users" size={23} />
          </span>
          <span>
            <small>DOCUMENTO COLECTIVO</small>
            <strong>Nómina de matriculados</strong>
            <em>Exporta los registros filtrados por periodo.</em>
          </span>
          <Icon name="chevron" size={19} className="report-select-arrow" />
        </button>
      </div>
      <div className="panel report-workspace">
        <div className="report-workspace-title">
          <div>
            <span className="eyebrow">GENERAR DOCUMENTO</span>
            <h2>
              {selected === "constancia"
                ? "Constancia de matrícula"
                : "Nómina de matriculados"}
            </h2>
            <p>
              {selected === "constancia"
                ? "Busca un estudiante por DNI o código para emitir su constancia."
                : "Define los criterios de la nómina antes de exportarla."}
            </p>
          </div>
          <span className="format-chip">
            {selected === "constancia" ? "PDF" : "PDF · EXCEL"}
          </span>
        </div>
        {selected === "constancia" ? (
          <>
            <div className="report-search search-box">
              <Icon name="search" size={19} />
              <input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Buscar por DNI, código o nombre del estudiante..."
                aria-label="Buscar matrícula para constancia"
              />
            </div>
            {search.trim() && (
              <div className="report-results">
                <span className="results-label">
                  {matches.length} RESULTADO{matches.length === 1 ? "" : "S"}{" "}
                  ENCONTRADO{matches.length === 1 ? "" : "S"}
                </span>
                {matches.length ? matches.slice(0, 6).map((e) => (
                    <div className="report-result" key={e.code}>
                      <span className="student-avatar">
                        {e.first[0]}
                        {e.last[0]}
                      </span>
                      <div>
                        <strong>{fullName(e)}</strong>
                        <small>
                          DNI {e.dni} · {e.code} · {e.specialty}
                        </small>
                      </div>
                      <button
                        className="btn btn-outline"
                        onClick={() => onPrint("constancia", e.code)}
                      >
                        <Icon name="download" size={16} /> Generar PDF
                      </button>
                    </div>
                  )) : <p className="no-results">
                    No se encontraron matrículas vigentes para esta búsqueda.
                  </p>}
              </div>
            )}
          </>
        ) : (
          <>
            <div className="report-filter-grid">
              <Field label="Especialidad">
                <select
                  value={specialty}
                  onChange={(e) => setSpecialty(e.target.value)}
                >
                  <option value="">Todas las especialidades</option>
                  {specialtyNames.map((s) => (
                    <option key={s}>{s}</option>
                  ))}
                </select>
              </Field>
              <Field label="Turno">
                <select
                  value={shift}
                  onChange={(e) => setShift(e.target.value)}
                >
                  <option value="">Todos los turnos</option>
                  {shifts.map((s) => (
                    <option key={s}>{s}</option>
                  ))}
                </select>
              </Field>
              <Field label="Periodo">
                <select
                  value={period}
                  onChange={(e) => setPeriod(e.target.value)}
                >
                  <option>2026-I</option>
                  <option>2026-II</option>
                </select>
              </Field>
            </div>
            <div className="report-export-bar">
              <div>
                <strong>{rows.length} estudiantes vigentes</strong>
                <span>
                  Incluidos en el documento según los filtros seleccionados.
                </span>
              </div>
              <div className="report-buttons">
                <button
                  className="btn btn-outline"
                  disabled={!rows.length}
                  onClick={() => onPrint("nomina", undefined, rows)}
                >
                  <Icon name="printer" size={16} /> Exportar PDF
                </button>
                <button
                  className="btn btn-primary"
                  disabled={!rows.length}
                  onClick={() => onExcel(rows)}
                >
                  <Icon name="download" size={16} /> Exportar Excel
                </button>
              </div>
            </div>
          </>
        )}
      </div>
      <div className="panel table-panel history-panel">
        <div className="panel-header">
          <div>
            <h2>Historial de documentos</h2>
            <p>Archivos generados durante esta sesión</p>
          </div>
          <span className="table-count">{documents.length} documentos</span>
        </div>
        <div className="table-scroll">
          <table>
            <thead>
              <tr>
                <th>FECHA Y HORA</th>
                <th>TIPO DE DOCUMENTO</th>
                <th>DETALLE</th>
                <th>USUARIO</th>
                <th>FORMATO</th>
                <th>DESCARGA</th>
              </tr>
            </thead>
            <tbody>
              {documents.map((doc) => (
                <tr key={doc.id}>
                  <td>{doc.date}</td>
                  <td className="name-cell">{doc.type}</td>
                  <td>{doc.detail}</td>
                  <td>{doc.user}</td>
                  <td>
                    <span className="format-chip">{doc.format}</span>
                  </td>
                  <td>
                    <button
                      className="mini-action download-action"
                      onClick={() => download(doc)}
                      aria-label={`Volver a descargar ${doc.type}`}
                    >
                      <Icon name="download" size={16} /> Descargar
                    </button>
                  </td>
                </tr>
              ))}
              {!documents.length && (
                <tr>
                  <td className="empty-table" colSpan={6}>
                    <Icon name="file" size={23} />
                    <span>
                      Aún no hay documentos generados. Aparecerán aquí cuando
                      emitas uno.
                    </span>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  )
}

function AdministrationPage({
  users,
  setUsers,
  agreements,
  setAgreements,
}: {
  users: UserRecord[]
  setUsers: React.Dispatch<React.SetStateAction<UserRecord[]>>
  agreements: Agreement[]
  setAgreements: React.Dispatch<React.SetStateAction<Agreement[]>>
}) {
  const [tab, setTab] = useState("Usuarios")
  const [adding, setAdding] = useState(false)
  const [error, setError] = useState("")
  const [notice, setNotice] = useState("")
  const [user, setUser] = useState<UserRecord>({
    name: "",
    user: "",
    role: "Matrícula",
    status: "Activo",
  })
  const [agreement, setAgreement] = useState<Agreement>({
    name: "",
    percent: 25,
    validity: "",
    status: "Activo",
  })
  function changeTab(next: string) {
    setTab(next)
    setAdding(false)
    setError("")
    setNotice("")
  }
  function saveUser(e: React.FormEvent) {
    e.preventDefault()
    if (
      users.some((u) => u.user.toLowerCase() === user.user.trim().toLowerCase())
    ) {
      setError("Ese nombre de usuario ya existe.")
      return
    }
    setUsers((prev) => [
      ...prev,
      { ...user, name: user.name.trim(), user: user.user.trim().toLowerCase() },
    ])
    setUser({ name: "", user: "", role: "Matrícula", status: "Activo" })
    setAdding(false)
    setError("")
  }
  function saveAgreement(e: React.FormEvent) {
    e.preventDefault()
    if (agreement.percent > 50 || agreement.percent < 1) {
      setError("El porcentaje máximo permitido es 50%.")
      return
    }
    setAgreements((prev) => [
      ...prev,
      { ...agreement, name: agreement.name.trim() },
    ])
    setAgreement({ name: "", percent: 25, validity: "", status: "Activo" })
    setAdding(false)
    setError("")
  }
  return (
    <>
      <SectionHeading
        kicker="CONFIGURACIÓN / SISTEMA"
        title="Administración"
        description="Controla los accesos y los convenios de la institución."
      />
      <div className="management-summary">
        <span className="management-summary-icon">
          <Icon name="shield" size={22} />
        </span>
        <div>
          <strong>Configuración institucional</strong>
          <p>
            {users.length} usuarios registrados ·{" "}
            {agreements.filter((a) => a.status === "Activo").length} convenios
            activos
          </p>
        </div>
        <span className="summary-period">USO INTERNO</span>
      </div>
      <div className="management-tab-row">
        <Tabs
          items={["Usuarios", "Convenios"]}
          active={tab}
          onChange={changeTab}
        />
        <button
          className="btn btn-primary"
          onClick={() => {
            setAdding(true)
            setError("")
            setNotice("")
          }}
        >
          <Icon name="plus" size={17} />
          {tab === "Usuarios" ? "Nuevo usuario" : "Nuevo convenio"}
        </button>
      </div>
      {adding && (
        <form
          className="panel management-form"
          onSubmit={tab === "Usuarios" ? saveUser : saveAgreement}
        >
          <div className="management-form-head">
            <div>
              <span className="eyebrow">CONFIGURACIÓN</span>
              <h2>{tab === "Usuarios" ? "Nuevo usuario" : "Nuevo convenio"}</h2>
            </div>
            <button
              type="button"
              className="icon-button"
              aria-label="Cerrar formulario"
              onClick={() => setAdding(false)}
            >
              <Icon name="close" />
            </button>
          </div>
          <div className="form-grid">
            {tab === "Usuarios" ? (
              <>
                <Field label="Nombre completo" required>
                  <input
                    value={user.name}
                    onChange={(e) => setUser({ ...user, name: e.target.value })}
                    placeholder="Nombres y apellidos"
                    required
                  />
                </Field>
                <Field label="Usuario" required>
                  <input
                    value={user.user}
                    onChange={(e) => setUser({ ...user, user: e.target.value })}
                    placeholder="usuario.apellido"
                    required
                  />
                </Field>
                <Field label="Rol" required>
                  <select
                    value={user.role}
                    onChange={(e) => setUser({ ...user, role: e.target.value })}
                  >
                    <option>Administrador</option>
                    <option>Matrícula</option>
                    <option>Directivo</option>
                  </select>
                </Field>
                <Field label="Estado">
                  <select
                    value={user.status}
                    onChange={(e) =>
                      setUser({
                        ...user,
                        status: e.target.value as UserRecord["status"],
                      })
                    }
                  >
                    <option>Activo</option>
                    <option>Bloqueado</option>
                  </select>
                </Field>
              </>
            ) : (
              <>
                <Field label="Institución" required>
                  <input
                    value={agreement.name}
                    onChange={(e) =>
                      setAgreement({ ...agreement, name: e.target.value })
                    }
                    placeholder="Nombre de la institución"
                    required
                  />
                </Field>
                <Field
                  label="Porcentaje máximo (%)"
                  required
                  hint="No puede superar el 50%"
                >
                  <input
                    type="number"
                    min="1"
                    max="50"
                    value={agreement.percent}
                    onChange={(e) => {
                      setAgreement({
                        ...agreement,
                        percent: Number(e.target.value),
                      })
                      setError(
                        Number(e.target.value) > 50
                          ? "El porcentaje máximo permitido es 50%."
                          : "",
                      )
                    }}
                    required
                  />
                </Field>
                <Field label="Vigencia" required>
                  <input
                    value={agreement.validity}
                    onChange={(e) =>
                      setAgreement({ ...agreement, validity: e.target.value })
                    }
                    placeholder="Ej. 01/03/2026 – 31/12/2026"
                    required
                  />
                </Field>
                <Field label="Estado">
                  <select
                    value={agreement.status}
                    onChange={(e) =>
                      setAgreement({
                        ...agreement,
                        status: e.target.value as Agreement["status"],
                      })
                    }
                  >
                    <option>Activo</option>
                    <option>Inactivo</option>
                  </select>
                </Field>
              </>
            )}
          </div>
          {error && (
            <div className="error-box" role="alert">
              {error}
            </div>
          )}
          <div className="management-form-actions">
            <button
              type="button"
              className="btn btn-outline"
              onClick={() => setAdding(false)}
            >
              Cancelar
            </button>
            <button type="submit" className="btn btn-primary">
              Guardar {tab === "Usuarios" ? "usuario" : "convenio"}
            </button>
          </div>
        </form>
      )}
      {notice && (
        <div className="notice-box" role="status">
          <Icon name="check" size={17} />
          {notice}
          <button aria-label="Cerrar aviso" onClick={() => setNotice("")}>
            <Icon name="close" size={14} />
          </button>
        </div>
      )}
      <div className="panel table-panel">
        <div className="panel-header">
          <div>
            <h2>
              {tab === "Usuarios"
                ? "Usuarios del sistema"
                : "Convenios institucionales"}
            </h2>
            <p>
              {tab === "Usuarios"
                ? "Gestiona los perfiles y el estado de acceso"
                : "Beneficios y porcentajes autorizados para matrículas"}
            </p>
          </div>
          <span className="table-count">
            {tab === "Usuarios" ? users.length : agreements.length} registros
          </span>
        </div>
        <div className="table-scroll">
          {tab === "Usuarios" ? (
            <table>
              <thead>
                <tr>
                  <th>NOMBRE</th>
                  <th>USUARIO</th>
                  <th>ROL</th>
                  <th>ESTADO</th>
                  <th>ACCIONES</th>
                </tr>
              </thead>
              <tbody>
                {users.map((u, i) => (
                  <tr key={`${u.user}-${i}`}>
                    <td className="name-cell">
                      <div className="specialty-name">
                        <span className="admin-avatar">
                          {u.name
                            .split(" ")
                            .map((n) => n[0])
                            .slice(0, 2)
                            .join("")}
                        </span>
                        {u.name}
                      </div>
                    </td>
                    <td className="code-cell">@{u.user}</td>
                    <td>
                      <span className="role-pill">{u.role}</span>
                    </td>
                    <td>
                      <span
                        className={`badge ${
                          u.status === "Activo"
                            ? "badge-vigente"
                            : "badge-anulada"
                        }`}
                      >
                        <span className="badge-dot" />
                        {u.status}
                      </span>
                    </td>
                    <td>
                      <div className="admin-row-actions">
                        <button
                          className="mini-action"
                          onClick={() =>
                            setNotice(
                              `Contraseña restablecida para @${u.user}. Clave temporal: CJLA2026`,
                            )
                          }
                        >
                          Restablecer contraseña
                        </button>
                        <button
                          className="mini-action"
                          onClick={() =>
                            setUsers((prev) =>
                              prev.map((item, index) =>
                                index === i
                                  ? {
                                      ...item,
                                      status:
                                        item.status === "Activo"
                                          ? "Bloqueado"
                                          : "Activo",
                                    }
                                  : item,
                              ),
                            )
                          }
                        >
                          {u.status === "Activo" ? "Bloquear" : "Activar"}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <table>
              <thead>
                <tr>
                  <th>INSTITUCIÓN</th>
                  <th>PORCENTAJE MÁXIMO</th>
                  <th>VIGENCIA</th>
                  <th>ESTADO</th>
                  <th>ACCIÓN</th>
                </tr>
              </thead>
              <tbody>
                {agreements.map((a, i) => (
                  <tr key={`${a.name}-${i}`}>
                    <td className="name-cell">
                      <div className="specialty-name">
                        <span className="agreement-icon">
                          <Icon name="file" size={17} />
                        </span>
                        {a.name}
                      </div>
                    </td>
                    <td>
                      <span className="percent-pill">{a.percent}%</span>
                      <span className="percent-limit"> / 50% tope</span>
                    </td>
                    <td>{a.validity}</td>
                    <td>
                      <span
                        className={`badge ${
                          a.status === "Activo"
                            ? "badge-vigente"
                            : "badge-anulada"
                        }`}
                      >
                        <span className="badge-dot" />
                        {a.status}
                      </span>
                    </td>
                    <td>
                      <button
                        className="mini-action"
                        onClick={() =>
                          setAgreements((prev) =>
                            prev.map((item, index) =>
                              index === i
                                ? {
                                    ...item,
                                    status:
                                      item.status === "Activo"
                                        ? "Inactivo"
                                        : "Activo",
                                  }
                                : item,
                            ),
                          )
                        }
                      >
                        {a.status === "Activo" ? "Desactivar" : "Activar"}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
        <div className="panel-footer">
          <span>
            {tab === "Usuarios"
              ? "Cada usuario cuenta con un rol y permisos de acceso asignados."
              : "Ningún convenio puede superar el 50% de descuento."}
          </span>
          <span>Gestión institucional</span>
        </div>
      </div>
    </>
  )
}
