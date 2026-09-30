import {onRequest} from "firebase-functions/v2/https";
import * as mammoth from "mammoth";
import busboy = require("busboy");
import {Readable} from "stream";
import PDFParser from "pdf2json";

export const extractNotesText = onRequest(
  {
    timeoutSeconds: 120,
    memory: "512MiB",
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({status: "error", message: "Use POST."});
      return;
    }

    try {
      const {text, fileType} = await extractFromMultipart(req);

      if (!text.trim()) {
        res.status(400).json({
          status: "error",
          message: "Could not extract text from file. " +
"Make sure it contains readable text.",
        });
        return;
      }

      res.status(200).json({
        status: "success",
        text: text.trim(),
        fileType,
        charCount: text.trim().length,
      });
    } catch (error) {
      const err = error as Error;
      res.status(500).json({
        status: "error",
        message: err.message || "Extraction failed.",
      });
    }
  }
);

// ── Extract text from PDF buffer using pdf2json ──

function extractPdfText(buffer: Buffer): Promise<string> {
  return new Promise((resolve, reject) => {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const pdfParser = new (PDFParser as any)(null, 1);

    pdfParser.on("pdfParser_dataReady", () => {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const text = (pdfParser as any).getRawTextContent() as string;
      resolve(text);
    });

    pdfParser.on("pdfParser_dataError", (err: {parserError: Error}) => {
      reject(err.parserError);
    });

    pdfParser.parseBuffer(buffer);
  });
}

// ── Parse multipart form and extract text ────────────────────────────────────

async function extractFromMultipart(
// eslint-disable-next-line @typescript-eslint/no-explicit-any
  req: any
): Promise<{text: string; fileType: string}> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    let fileType = "";

    const bb = busboy({headers: req.headers});

    bb.on("file", (
      _name: string,
      file: NodeJS.ReadableStream,
      info: {filename: string}
    ) => {
      const {filename} = info;
      if (filename.endsWith(".pdf")) {
        fileType = "pdf";
      } else if (filename.endsWith(".docx")) {
        fileType = "docx";
      } else {
        reject(new Error(
          "Unsupported file type. Upload PDF (.pdf) or Word (.docx)."
        ));
        return;
      }

      (file as NodeJS.EventEmitter).on("data", (chunk: Buffer) => {
        chunks.push(chunk);
      });
    });

    bb.on("finish", async () => {
      try {
        const buffer = Buffer.concat(chunks);
        let text = "";

        if (fileType === "pdf") {
          text = await extractPdfText(buffer);
        } else if (fileType === "docx") {
          const result = await mammoth.extractRawText({buffer});
          text = result.value;
        }

        resolve({text, fileType});
      } catch (err) {
        reject(err);
      }
    });

    bb.on("error", reject);

    // Firebase Functions v2 pre-parses body — use rawBody to re-stream
    if (req.rawBody) {
      const stream = new Readable();
      stream.push(req.rawBody);
      stream.push(null);
      stream.pipe(bb);
    } else {
      req.pipe(bb);
    }
  });
}
